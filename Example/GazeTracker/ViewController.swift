//
//  ViewController.swift
//  GazeTracker
//
//  Created by ReQEnoxus on 11/27/2021.
//  Copyright (c) 2021 ReQEnoxus. All rights reserved.
//

import UIKit
import ARKit
import NotificationBannerSwift

class ViewController: UIViewController {
    
    private lazy var pointer: UIView = {
        let pointer = UIView(frame: CGRect(origin: .zero, size: .init(width: 10, height: 10)))
        pointer.backgroundColor = .red
        pointer.layer.cornerRadius = 5
        
        return pointer
    }()
    
    private lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.automaticallyUpdatesLighting = true
        sceneView.loops = true
        return sceneView
    }()
    
    private lazy var predictedPointLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var predictedDistanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var dots: [UIView] = (0...5).map { _ in
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        let gesture = BlinkGestureRecognizer(target: self, action: #selector(self.handleBlinkGesture(_:)))
        view.addGestureRecognizer(gesture)
        
        return view
    }
    
    private lazy var topButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("TOP BUTTON", for: .normal)
        button.addGestureRecognizer(GazeGestureRecognizer(target: self, action: #selector(self.handleGazeGesture(_:))))
        button.addGestureRecognizer(GazeGestureRecognizer(target: self, action: #selector(self.handleGazeGesture2(_:))))
        let blinkGesture = BlinkGestureRecognizer(target: self, action: #selector(self.handleBlinkGesture(_:)))
        button.gestureRecognizers?.first(where: { $0 is GazeGestureRecognizer })?.delegate = self
        blinkGesture.blinkType = .leftEye
        button.addGestureRecognizer(blinkGesture)
        button.alpha = 0.5
        
        return button
    }()
    
    private var doubleBlinkRecognizer: BlinkGestureRecognizer!
    private var secondDoubleBlinkRecognizer: BlinkGestureRecognizer!
    
    private lazy var middleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("MIDDLE BUTTON", for: .normal)
//        button.addGestureRecognizer(GazeGestureRecognizer(target: self, action: #selector(self.handleGazeGesture(_:))))
        let blinkGesture = BlinkGestureRecognizer(target: self, action: #selector(self.handleBlinkGesture(_:)))
        blinkGesture.name = "SingleBlink"
        blinkGesture.blinkType = .bothEyes
        blinkGesture.delegate = self
        
        let blinkGesture2 = BlinkGestureRecognizer(target: self, action: #selector(self.handleBlinkGesture(_:)))
        blinkGesture2.name = "DoubleBlink"
        blinkGesture2.blinkType = .bothEyes
        blinkGesture2.blinkCount = 2
        blinkGesture2.maximumBlinkInterval = .milliseconds(600)
        
        let blinkGesture3 = BlinkGestureRecognizer(target: self, action: #selector(self.handleBlinkGesture(_:)))
        blinkGesture3.name = "SecondDoubleBlink"
        blinkGesture3.blinkType = .bothEyes
        blinkGesture3.blinkCount = 2
        blinkGesture3.maximumBlinkInterval = .milliseconds(600)
        
        self.doubleBlinkRecognizer = blinkGesture2
        self.secondDoubleBlinkRecognizer = blinkGesture3
        
        button.addGestureRecognizer(blinkGesture)
        button.addGestureRecognizer(blinkGesture2)
        button.addGestureRecognizer(blinkGesture3)
        button.alpha = 0.5
        
        return button
    }()
    
    private lazy var bottomButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("BOTTOM BUTTON", for: .normal)
        button.addGestureRecognizer(GazeGestureRecognizer(target: self, action: #selector(self.handleGazeGesture(_:))))
        
        let secondGazeRecognizer = GazeGestureRecognizer(target: self, action: #selector(self.handleGazeGesture2(_:)))
        button.addGestureRecognizer(secondGazeRecognizer)
        secondGazeRecognizer.delegate = self
//        let longGazeRecognizer = LongGazeGestureRecognizer(target: self, action: #selector(self.handleLongGazeGesture(_:)))
//        longGazeRecognizer.gazeInterval = .milliseconds(200)
//        longGazeRecognizer.toleranceInterval = .milliseconds(30)
//        button.addGestureRecognizer(longGazeRecognizer)
        
        let blinkGesture = BlinkGestureRecognizer(target: self, action: #selector(self.handleBlinkGesture(_:)))
        blinkGesture.blinkType = .bothEyes
        blinkGesture.blinkCount = 2
        blinkGesture.maximumBlinkInterval = .milliseconds(1000)
        button.addGestureRecognizer(blinkGesture)
        button.alpha = 0.5
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        EyeTrackingSystem.initializeWithCustomConfiguration(
            EyeTrackingConfiguration<ARKitTracker, EventDispatcher>
                .builder()
                .backend(
                    config: ARKitTrackerConfiguration(
                        blinkFrameOffset: 20,
                        leftEyeBlinkThreshold: 0.3,
                        rightEyeBlinkThreshold: 0.3,
                        sceneView: self.sceneView
                    )
                )
                .frontend(config: EventDispatcherConfiguration(displayGazeLocation: true))
                .build()
        )
        EyeTrackingSystem.startTracking()
        
        self.view.backgroundColor = .white
        self.view.addSubview(self.sceneView)
        self.view.addSubview(self.topButton)
        self.view.addSubview(self.middleButton)
//        self.view.addSubview(self.bottomButton)
//        self.view.addSubview(self.predictedPointLabel)
//        self.view.addSubview(self.predictedDistanceLabel)
//        self.dots.forEach { self.view.addSubview($0) }
//        self.view.addSubview(self.pointer)
        
        sceneView.debugOptions = [.showWorldOrigin]

//        let sizeConstraints = self.dots.flatMap {
//            return [
//                $0.widthAnchor.constraint(equalToConstant: 50),
//                $0.heightAnchor.constraint(equalToConstant: 50)
//            ]
//        }
        
        let constraints = [
            self.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.topButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -200),
            self.topButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 48),
            self.topButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -48),
            self.topButton.heightAnchor.constraint(equalToConstant: 90),
            
            self.middleButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.middleButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 48),
            self.middleButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -48),
            self.middleButton.heightAnchor.constraint(equalToConstant: 90),
            
//            self.bottomButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 200),
//            self.bottomButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 48),
//            self.bottomButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -48),
//            self.bottomButton.heightAnchor.constraint(equalToConstant: 90),
            
//            self.predictedPointLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
//            self.predictedPointLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
//            self.predictedPointLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//
//            self.predictedDistanceLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
//            self.predictedDistanceLabel.topAnchor.constraint(equalTo: self.predictedPointLabel.bottomAnchor),
//            self.predictedDistanceLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//
//            self.dots[0].topAnchor.constraint(equalTo: self.predictedDistanceLabel.bottomAnchor, constant: 24),
//            self.dots[0].leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
//
//            self.dots[1].centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
//            self.dots[1].leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
//
//            self.dots[2].leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
//            self.dots[2].bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
//
//            self.dots[3].bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
//            self.dots[3].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
//
//            self.dots[4].centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
//            self.dots[4].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
//
//            self.dots[5].topAnchor.constraint(equalTo: self.predictedDistanceLabel.bottomAnchor, constant: 24),
//            self.dots[5].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
        ]// + sizeConstraints
        
        NSLayoutConstraint.activate(constraints)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func handleGazeGesture(_ gestureRecognizer: GazeGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            animateViewIn(gestureRecognizer.view)
            
        case .ended:
            animateViewOut(gestureRecognizer.view)
            
        default:
            break
        }
    }
    
    @objc private func handleGazeGesture2(_ gestureRecognizer: GazeGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            animateViewIn(gestureRecognizer.view, type: 2)
            
        case .ended:
            animateViewOut(gestureRecognizer.view, type: 2)
            
        default:
            break
        }
    }
    
    @objc private func handleLongGazeGesture(_ gestureRecognizer: LongGazeGestureRecognizer) {
        animateViewIn(gestureRecognizer.view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.animateViewOut(gestureRecognizer.view)
        }
    }
    
    @objc private func handleBlinkGesture(_ gestureRecognizer: BlinkGestureRecognizer) {
        switch gestureRecognizer.view {
        case topButton:
            NotificationBannerQueue.default.removeAll()
            NotificationBanner(title: "Top Button Activated")
                .show(queuePosition: .front, bannerPosition: .top, queue: .default)
            activateAnimation(topButton)
        case middleButton:
            NotificationBannerQueue.default.removeAll()
            NotificationBanner(title: "Middle Button Activated")
                .show(queuePosition: .front, bannerPosition: .top, queue: .default)
            activateAnimation(middleButton)
        case bottomButton:
            NotificationBannerQueue.default.removeAll()
            NotificationBanner(title: "Bottom Button Activated")
                .show(queuePosition: .front, bannerPosition: .top, queue: .default)
            activateAnimation(bottomButton)
        default:
            break
        }
    }
    
    private func activateAnimation(_ view: UIView?) {
        guard let view = view else { return }
        
        UIView.animate(withDuration: 0.2, delay: .zero, options: [.autoreverse]) {
            view.backgroundColor = .systemRed
        }
    }
    
    private func animateViewIn(_ view: UIView?, type: Int = 1) {
        guard let view = view else { return }
        
        UIView.animate(withDuration: 0.2) {
            if type == 1 {
                view.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                view.backgroundColor = .systemGreen
            } else {
                view.layer.cornerRadius = 30
            }
        }
    }
    
    private func animateViewOut(_ view: UIView?, type: Int = 1) {
        guard let view = view else { return }
        
        UIView.animate(withDuration: 0.2) {
            if type == 1 {
                view.transform = .identity
                view.backgroundColor = .systemBlue
            } else {
                view.layer.cornerRadius = 8
            }
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer == doubleBlinkRecognizer || otherGestureRecognizer == secondDoubleBlinkRecognizer
    }
}

extension ViewController: GazeTrackingBackendDelegate {
    
    func tracker(didEmit event: GazeTrackingEvent) {
//        var bannerText: String?
//        switch event.name {
//        case .rightEyeBlink:
//            bannerText = "Right Eye Blink"
//        case .leftEyeBlink:
//            bannerText = "Left Eye Blink"
//        case .bothEyesBlink:
//            bannerText = "Both Eyes Blink"
//        default:
//            break
//        }
//
//        if let bannerText = bannerText {
//
//            let view = UIView(frame: .init(origin: .zero, size: CGSize(width: 30, height: 30)))
//            view.backgroundColor = .systemBlue
//            view.layer.cornerRadius = 15
//            self.view.addSubview(view)
//            view.center = event.screenPoint
//
//            UIView.animate(withDuration: 1) {
//                view.alpha = 0
//            } completion: { _ in
//                view.removeFromSuperview()
//            }
//
//            NotificationBannerQueue.default.removeAll()
//            NotificationBanner(title: bannerText)
//                .show(queuePosition: .front, bannerPosition: .top, queue: .default)
//        }
        
        self.pointer.center = event.screenPoint
        
//        self.dots.forEach({ view in
//            if self.pointer.frame.intersects(view.frame) {
//                view.backgroundColor = .green
//            } else {
//                view.backgroundColor = .white
//            }
//        })
        
        self.predictedPointLabel.text = "Predicted screen point: (\(round(event.screenPoint.x)), \(round(event.screenPoint.y)))"
        self.predictedDistanceLabel.text = "Predicted distance to screen: \(event.screenDistance) m."
    }
}

