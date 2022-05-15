//
//  PrecisionTestViewController.swift
//  GazeTracker_Example
//
//  Created by Enoxus on 20.02.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import ARKit
import UIKit
import DeviceKit

final class PrecisionTestViewController: UIViewController {
    private enum Constants {
        static let inset: CGFloat = 24.0
    }
    
    private var path: [CGPoint] = []
    
    private lazy var idealPointView: UIView = {
        let view = UIView(frame: CGRect(x: .zero, y: .zero, width: 10, height: 10))
        view.layer.cornerRadius = 5
        view.backgroundColor = .systemGreen
        
        return view
    }()
    
    private lazy var predictedPointView: UIView = {
        let view = UIView(frame: CGRect(x: .zero, y: .zero, width: 10, height: 10))
        view.layer.cornerRadius = 5
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let tracker = ARKitTracker()
    
    private lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.automaticallyUpdatesLighting = true
        sceneView.loops = true
        return sceneView
    }()
    
    private var totalDist: Float = 0
    private var totalError: Double = 0
    private var numberOfMeasures: Double = 0
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .white
        self.view.addSubview(self.sceneView)
        self.view.addSubview(self.idealPointView)
        self.view.addSubview(self.predictedPointView)
        
        NSLayoutConstraint.activate([
            self.sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initPath()
        self.initTracker()
        self.startAnimation()
    }
    
    private func initTracker() {
//        self.sceneView.session = tracker.currentSession
//        tracker.startSession(scene: self.sceneView.scene)
    }
    
    private func measure() {
        tracker.delegate = self
    }
    
    private func endMeasure() {
        tracker.delegate = nil
        let meanError = self.totalError / self.numberOfMeasures
        let phoneScreenSize = Device.current.realScreenSize // iphone 12 mini for now
        let meanErrorCm = (meanError / self.view.frame.height) * (phoneScreenSize.height * 100)
        let meanDist = self.totalDist / Float(self.numberOfMeasures)
        print("Mean Error = \(meanError) (\(meanErrorCm) cm.), dist: \(meanDist)")
    }
    
    private func initPath() {
        let frame = self.view.frame
        
        self.path = [
            .init(x: frame.origin.x + Constants.inset, y: frame.origin.y + Constants.inset), // left top
            .init(x: frame.origin.x + Constants.inset, y: frame.height - Constants.inset), // left bottom
            .init(x: frame.width - Constants.inset, y: frame.height - Constants.inset), // right bottom
            .init(x: frame.width - Constants.inset, y: frame.origin.y + Constants.inset), // right top
            .init(x: frame.midX, y: frame.midY), // center
            .init(x: frame.origin.x + Constants.inset, y: frame.height - Constants.inset), // left bottom
            .init(x: frame.midX, y: frame.midY), // center
            .init(x: frame.width - Constants.inset, y: frame.height - Constants.inset), // right bottom
            .init(x: frame.midX, y: frame.midY), // center
            .init(x: frame.origin.x + Constants.inset, y: frame.origin.y + Constants.inset), // left top
            .init(x: frame.midX, y: frame.midY), // center
        ]
    }
    
    private func startAnimation() {
        let startingPoint = self.path[0]
        self.idealPointView.center = startingPoint
        
        let correctedPath = Array(path.dropFirst())
        
        self.measure()
        UIView.animateKeyframes(withDuration: Double(correctedPath.count) * 2, delay: .zero, options:[.calculationModeLinear]) {
            correctedPath.enumerated().forEach { (index, point) in
                UIView.addKeyframe(
                    withRelativeStartTime: Double(index) / Double(correctedPath.count),
                    relativeDuration: 1.0 / Double(correctedPath.count)) {
                        print("DurationForPoint: \(point) = \(1.0 / Double(correctedPath.count) * Double(correctedPath.count) * 2)")
                        self.idealPointView.center = point
                    }
            }
        } completion: { _ in
            self.endMeasure()
        }

    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> Double {
        return sqrt(
            (other.x - self.x) * (other.x - self.x) +
            (other.y - self.y) * (other.y - self.y)
        )
    }
}

extension PrecisionTestViewController: GazeTrackingBackendDelegate {
    func tracker(didEmit event: GazeTrackingEvent) {
        self.predictedPointView.center = event.screenPoint
        guard let idealPosition = self.idealPointView.layer.presentation()?.position else { return }
        let prediction = event.screenPoint
        self.totalError += prediction.distance(to: idealPosition)
        self.totalDist += event.screenDistance
        self.numberOfMeasures += 1
    }
}
