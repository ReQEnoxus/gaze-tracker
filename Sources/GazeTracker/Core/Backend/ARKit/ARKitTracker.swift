//
//  ARKitTracker.swift
//  GazeTracker
//
//  Created by Enoxus on 27.11.2021.
//

import ARKit
import SceneKit
import Foundation
import DeviceKit

public class ARKitTracker: NSObject, BackendLayerProtocol {
    
    // MARK: - Public Properties
    
    public weak var delegate: GazeTrackingBackendDelegate?
    
    // MARK: - Private Properties
    
    private let currentSession = ARSession()
    private let scene = SCNScene()
    
    private var configuration = ARKitTrackerConfiguration()
    
    private let faceNode: SCNNode = SCNNode()
    private let debouncer = Debouncer(timeInterval: .milliseconds(20))

    private lazy var leftEyeRay: SCNNode = createCylinder(color: .systemGreen)
    private lazy var rightEyeRay: SCNNode = createCylinder(color: .systemGreen)
    private lazy var gazeRay: SCNNode = createCylinder(color: .systemRed)
    
    private lazy var screenPlane: SCNNode = {
        let screenGeometry = SCNPlane(width: 1, height: 1)
        let superNode = SCNNode()
        let node = SCNNode(geometry: screenGeometry)
        screenGeometry.materials.first?.diffuse.contents = UIColor.systemGray
        superNode.addChildNode(node)
        
        return superNode
    }()
    
    private var lookAtTargetEyeLNode: SCNNode = SCNNode()
    private var lookAtTargetEyeRNode: SCNNode = SCNNode()
    
    private var gazeTargetNode: SCNNode = SCNNode()
    
    private var smoothingWindow = SlidingAverageableWindow<CGPoint>(capacity: 10)
    
    // MARK: - Initializers
    
    public required override init() {
        super.init()
    }
    
    // MARK: - Private Methods
    
    private func createCylinder(color: UIColor) -> SCNNode {
        let cylinder = SCNCylinder(radius: 0.001, height: 2)
        cylinder.materials.first?.diffuse.contents = color
        let node = SCNNode(geometry: cylinder)
        node.eulerAngles.x = -.pi / 2
        
        let parent = SCNNode()
        parent.addChildNode(node)
        
        return parent
    }
    
    private func setupSceneGraph(scene: SCNScene? = nil) {
        let scene = scene ?? self.scene
        scene.rootNode.addChildNode(faceNode)
        scene.rootNode.addChildNode(screenPlane)
        faceNode.addChildNode(leftEyeRay)
        faceNode.addChildNode(rightEyeRay)
        faceNode.addChildNode(gazeRay)
        leftEyeRay.addChildNode(lookAtTargetEyeLNode)
        rightEyeRay.addChildNode(lookAtTargetEyeRNode)
        gazeRay.addChildNode(gazeTargetNode)
        
        lookAtTargetEyeLNode.position.z = 2
        lookAtTargetEyeRNode.position.z = 2
        gazeTargetNode.position.z = 1
    }
    
    // MARK: - Public Methods
    
    public func configure(with configuration: ARKitTrackerConfiguration) {
        self.configuration = configuration
        smoothingWindow = SlidingAverageableWindow<CGPoint>(capacity: configuration.blinkFrameOffset + 1)
        configuration.sceneView?.session = currentSession
    }
    
    public func startTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            NSLog("Face tracking not supported on this device.")
            return
        }

        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1
        
        setupSceneGraph(scene: self.configuration.sceneView?.scene)

        currentSession.delegate = self
        currentSession.run(
            configuration,
            options: [
                .resetTracking,
                .removeExistingAnchors
            ]
        )
    }
    
    public func endTracking() {
        currentSession.pause()
    }
}

extension ARKitTracker: ARSCNViewDelegate, ARSessionDelegate {
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let anchor = frame.anchors.first as? ARFaceAnchor else { return }

        faceNode.simdTransform = anchor.transform
        leftEyeRay.simdTransform = anchor.leftEyeTransform
        rightEyeRay.simdTransform = anchor.rightEyeTransform
        gazeRay.simdTransform = anchor.leftEyeTransform.average(with: anchor.rightEyeTransform)
        
        screenPlane.simdTransform = frame.camera.transform

        let hitTestResults = screenPlane.hitTestWithSegment(
            from: gazeTargetNode.worldPosition,
            to: gazeRay.worldPosition,
            options: nil
        )
        guard let hitTestCoordinates = hitTestResults.last?.localCoordinates else { return }
        
        let smoothPoint = configuration.coordinateMapper.mapCoordinates(
            from: CGPoint(
                x: CGFloat(hitTestCoordinates.x),
                y: CGFloat(hitTestCoordinates.y)
            )
        )
        
        smoothingWindow.append(smoothPoint)
        
        let distance = (gazeRay.worldPosition - SCNVector3Zero).length()
        
        processBlendShapes(anchor.blendShapes, for: smoothingWindow, dist: distance)
        
        delegate?.tracker(
            didEmit: GazeTrackingEvent(
                name: .gazePositionChanged,
                screenPoint: smoothPoint,
                screenDistance: distance,
                userInfo: nil
            )
        )
    }
    
    private func processBlendShapes(_ shapes: [ARFaceAnchor.BlendShapeLocation : NSNumber], for window: SlidingAverageableWindow<CGPoint>, dist: Float) {
        let leftEyeBlinkProbability = shapes[.eyeBlinkRight]
        let rightEyeBlinkProbabiltity = shapes[.eyeBlinkLeft]
        
        var leftEyeBlinked = false
        var rightEyeBlinked = false
        
        if let leftProb = leftEyeBlinkProbability, leftProb.floatValue > configuration.leftEyeBlinkThreshold {
            leftEyeBlinked = true
        }
        
        if let rightProb = rightEyeBlinkProbabiltity, rightProb.floatValue > configuration.rightEyeBlinkThreshold {
            rightEyeBlinked = true
        }
        
        var name: GazeTrackingEvent.Name = .gazePositionChanged
        switch (leftEyeBlinked, rightEyeBlinked) {
        case (true, true):
            name = .bothEyesBlink
        case (true, false):
            name = .leftEyeBlink
        case (false, true):
            name = .rightEyeBlink
        case (false, false):
            return
        }
        
        var point = window.contents.last ?? .zero
        if configuration.blinkFrameOffset < window.contents.count {
            point = window.contents[window.contents.endIndex - configuration.blinkFrameOffset]
        }
        
        debouncer.debounce { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.tracker(
                didEmit: GazeTrackingEvent(
                    name: name,
                    screenPoint: point,
                    screenDistance: dist,
                    userInfo: nil
                )
            )
        }
    }
}
