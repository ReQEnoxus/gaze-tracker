//
//  ViewController.swift
//  GazeTracker
//
//  Created by ReQEnoxus on 11/27/2021.
//  Copyright (c) 2021 ReQEnoxus. All rights reserved.
//

import UIKit
import ARKit
import GazeTracker
import NotificationBannerSwift

class ViewController: UIViewController {
    
    private let tracker = ARKitTracker()
    
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
    
    private var dots: [UIView] = (0...5).map { _ in
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.sceneView)
        self.view.addSubview(self.predictedPointLabel)
        self.view.addSubview(self.predictedDistanceLabel)
        self.dots.forEach { self.view.addSubview($0) }
        self.view.addSubview(self.pointer)
        self.sceneView.session = tracker.currentSession
        sceneView.debugOptions = [.showWorldOrigin]

        tracker.startSession(scene: self.sceneView.scene)
        tracker.delegate = self

        let sizeConstraints = self.dots.flatMap {
            return [
                $0.widthAnchor.constraint(equalToConstant: 50),
                $0.heightAnchor.constraint(equalToConstant: 50)
            ]
        }
        
        let constraints = [
            self.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.predictedPointLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
            self.predictedPointLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.predictedPointLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            self.predictedDistanceLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
            self.predictedDistanceLabel.topAnchor.constraint(equalTo: self.predictedPointLabel.bottomAnchor),
            self.predictedDistanceLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            self.dots[0].topAnchor.constraint(equalTo: self.predictedDistanceLabel.bottomAnchor, constant: 24),
            self.dots[0].leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            
            self.dots[1].centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.dots[1].leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            
            self.dots[2].leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            self.dots[2].bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            
            self.dots[3].bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            self.dots[3].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            
            self.dots[4].centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.dots[4].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            
            self.dots[5].topAnchor.constraint(equalTo: self.predictedDistanceLabel.bottomAnchor, constant: 24),
            self.dots[5].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
        ] + sizeConstraints
        
        NSLayoutConstraint.activate(constraints)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: GazeTrackingBackendDelegate {
    func tracker(didEmit event: GazeTrackingEvent) {
        var bannerText: String?
        switch event.name {
        case .rightEyeBlink:
            bannerText = "Right Eye Blink"
        case .leftEyeBlink:
            bannerText = "Left Eye Blink"
        case .bothEyesBlink:
            bannerText = "Both Eyes Blink"
        default:
            break
        }
        
        if let bannerText = bannerText {
            
            let view = UIView(frame: .init(origin: .zero, size: CGSize(width: 30, height: 30)))
            view.backgroundColor = .systemBlue
            view.layer.cornerRadius = 15
            self.view.addSubview(view)
            view.center = event.screenPoint
            
            UIView.animate(withDuration: 1) {
                view.alpha = 0
            } completion: { _ in
                view.removeFromSuperview()
            }

            NotificationBannerQueue.default.removeAll()
            NotificationBanner(title: bannerText)
                .show(queuePosition: .front, bannerPosition: .top, queue: .default)
        }
        
        self.pointer.center = event.screenPoint
        
        self.dots.forEach({ view in
            if self.pointer.frame.intersects(view.frame) {
                view.backgroundColor = .green
            } else {
                view.backgroundColor = .white
            }
        })
        
        self.predictedPointLabel.text = "Predicted screen point: (\(round(event.screenPoint.x)), \(round(event.screenPoint.y)))"
        self.predictedDistanceLabel.text = "Predicted distance to screen: \(event.screenDistance) m."
    }
}

