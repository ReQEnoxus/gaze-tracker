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

class ViewController: UIViewController {
    
    private let tracker = Tracker(image: UIImage(named: "texture")!)
    
    private lazy var verticalSensitivitySlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 10.0
        slider.minimumValue = -10.0
        slider.value = UserDefaults.standard.float(forKey: "vertical-sens")
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isUserInteractionEnabled = true
        return slider
    }()
    
    private lazy var horizontalSensitivitySlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 10.0
        slider.minimumValue = -10.0
        slider.value = UserDefaults.standard.float(forKey: "horizontal-sens")
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isUserInteractionEnabled = true
        return slider
    }()
    
    private lazy var verticalSiderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Vertical Sens: \(UserDefaults.standard.float(forKey: "vertical-sens"))"
        
        return label
    }()
    
    private lazy var horizontalSiderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Horizontal Sens: \(UserDefaults.standard.float(forKey: "horizontal-sens"))"
        
        return label
    }()
    
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
//        self.view.addSubview(self.horizontalSensitivitySlider)
//        self.view.addSubview(self.verticalSensitivitySlider)
//        self.view.addSubview(self.horizontalSiderLabel)
//        self.view.addSubview(self.verticalSiderLabel)
        self.view.addSubview(self.pointer)
        self.sceneView.session = tracker.currentSession
        tracker.pointOfView = self.sceneView.pointOfView
        tracker.startSession(scene: self.sceneView.scene)
        self.verticalSensitivitySlider.addTarget(self, action: #selector(self.handleVerticalSlider), for: .valueChanged)
        self.horizontalSensitivitySlider.addTarget(self, action: #selector(self.handleHorizontalSlider), for: .valueChanged)
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
            
//            self.verticalSensitivitySlider.bottomAnchor.constraint(equalTo: self.horizontalSiderLabel.topAnchor, constant: -36),
//            self.verticalSensitivitySlider.leadingAnchor.constraint(equalTo: self.dots[2].trailingAnchor, constant: 8),
//            self.verticalSensitivitySlider.trailingAnchor.constraint(equalTo: self.dots[3].leadingAnchor, constant: -8),
//
//            self.horizontalSensitivitySlider.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
//            self.horizontalSensitivitySlider.leadingAnchor.constraint(equalTo: self.dots[2].trailingAnchor, constant: 8),
//            self.horizontalSensitivitySlider.trailingAnchor.constraint(equalTo: self.dots[3].leadingAnchor, constant: -8),
//
//            self.horizontalSiderLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            self.horizontalSiderLabel.bottomAnchor.constraint(equalTo: self.horizontalSensitivitySlider.topAnchor, constant: -8),
//
//            self.verticalSiderLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            self.verticalSiderLabel.bottomAnchor.constraint(equalTo: self.verticalSensitivitySlider.topAnchor, constant: -8),
            
            self.dots[3].bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            self.dots[3].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            
            self.dots[4].centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.dots[4].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            
            self.dots[5].topAnchor.constraint(equalTo: self.predictedDistanceLabel.bottomAnchor, constant: 24),
            self.dots[5].trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
        ] + sizeConstraints
        
        NSLayoutConstraint.activate(constraints)
        tracker.didUpdatePrediction = { [weak self] info in
            guard let self = self else { return }
            self.pointer.center = info.predictedPoint
            
            self.dots.forEach({ view in
                if self.pointer.frame.intersects(view.frame) {
                    view.backgroundColor = .green
                } else {
                    view.backgroundColor = .white
                }
            })
            
            self.predictedPointLabel.text = "Predicted screen point: (\(round(info.predictedPoint.x)), \(round(info.predictedPoint.y)))"
            self.predictedDistanceLabel.text = "Predicted distance to screen: \(info.predictedDistance) m."
        }
    }
    
    @objc func handleVerticalSlider() {
        self.verticalSiderLabel.text = "Vertical Sens: \(self.verticalSensitivitySlider.value)"
        UserDefaults.standard.set(self.verticalSensitivitySlider.value, forKey: "vertical-sens")
        self.tracker.verticalSensitivity = self.verticalSensitivitySlider.value
    }
    
    @objc func handleHorizontalSlider() {
        self.horizontalSiderLabel.text = "Horizontal Sens: \(self.horizontalSensitivitySlider.value)"
        UserDefaults.standard.set(self.horizontalSensitivitySlider.value, forKey: "horizontal-sens")
        self.tracker.horizontalSensitivity = self.horizontalSensitivitySlider.value
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

