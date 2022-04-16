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

public class ARKitTracker: NSObject {
    
    // MARK: - Public Properties
    
    public weak var delegate: GazeTrackingBackendDelegate?
    
    public var leftEyeBlinkSensitivity: Float = 0.5
    public var rightEyeBlinkSensitivity: Float = 0.5
    
    public var blinkTimingOffset: Int = 9
    
    public let currentSession = ARSession()
    public let scene = SCNScene()
    
    // MARK: - Scene
    
    private let faceNode: SCNNode = SCNNode()
    private let debouncer = Debouncer(timeInterval: .milliseconds(20))

    private var eyeLNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.002, bottomRadius: 0, height: 2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.systemGreen
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var eyeRNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.002, bottomRadius: 0, height: 2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.systemGreen
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    
    var gazeNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.002, bottomRadius: 0, height: 2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.white
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = .pi / 2
        node.position.z = 0
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    private var virtualPhoneNode: SCNNode = SCNNode()
    
    private lazy var virtualScreenNode: SCNNode = {
        
        let screenGeometry = SCNPlane(width: 1, height: 1)
//        let screenGeometry = SCNPlane(width: 0.1, height: 0.05)
        
        let superNode = SCNNode()
        let node = SCNNode(geometry: screenGeometry)

        screenGeometry.firstMaterial?.diffuse.contents = UIColor.systemGray

//        node.position.z = -0.15
//
//        let xGeom = SCNPlane(width: 0.05, height: 0.005)
//        xGeom.firstMaterial?.diffuse.contents = UIColor.red
//        let xGeomNode = SCNNode(geometry: xGeom)
//        xGeomNode.position.z = 0.0001
//        xGeomNode.position.x = 0.025
//        node.addChildNode(xGeomNode)
//
//        let yGeom = SCNPlane(width: 0.025, height: 0.005)
//        yGeom.firstMaterial?.diffuse.contents = UIColor.green
//        let yGeomNode = SCNNode(geometry: yGeom)
//        yGeomNode.position.z = 0.0002
//        yGeomNode.position.y = 0.0125
//        yGeomNode.eulerAngles.z = .pi/2
//        node.addChildNode(yGeomNode)
//
        superNode.addChildNode(node)
        
        return superNode
    }()
    
    private var lookAtTargetEyeLNode: SCNNode = SCNNode()
    private var lookAtTargetEyeRNode: SCNNode = SCNNode()
    
    private var gazeTargetNode: SCNNode = SCNNode()
    
    // MARK: - Cache
    
    private var smoothingWindow = SlidingAverageableWindow<CGPoint>(capacity: 10)
    
    // MARK: - Device Measurements
    
    public func startSession(scene: SCNScene? = nil) {
        guard ARFaceTrackingConfiguration.isSupported else {
            assertionFailure("Face tracking not supported on this device.")
            return
        }

        // Configure and start the ARSession to begin face tracking.
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1
//        configuration.worldAlignment = .gravity
        
        self.setupSceneGraph(scene: scene)

        self.currentSession.delegate = self
        self.currentSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func setupSceneGraph(scene: SCNScene? = nil) {
        let scene = scene ?? self.scene
        let pointOfView = scene.rootNode
        let sphere = SCNSphere(radius: 0.10)
        sphere.firstMaterial?.diffuse.contents = UIColor.gray
        let sphereNode = SCNNode(geometry: sphere)
        pointOfView.addChildNode(sphereNode)
        scene.rootNode.addChildNode(faceNode)
        pointOfView.addChildNode(virtualPhoneNode)
        self.virtualPhoneNode.addChildNode(virtualScreenNode)
        self.faceNode.addChildNode(eyeLNode)
        self.faceNode.addChildNode(eyeRNode)
        self.faceNode.addChildNode(gazeNode)
        self.eyeLNode.addChildNode(lookAtTargetEyeLNode)
        self.eyeRNode.addChildNode(lookAtTargetEyeRNode)
        self.gazeNode.addChildNode(gazeTargetNode)
        
        self.lookAtTargetEyeLNode.position.z = 2
        self.lookAtTargetEyeRNode.position.z = 2
        self.gazeTargetNode.position.z = 1
    }
}

extension ARKitTracker: ARSCNViewDelegate, ARSessionDelegate {
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let anchor = frame.anchors.first as? ARFaceAnchor else { return }

        faceNode.simdTransform = anchor.transform
        eyeLNode.simdTransform = anchor.leftEyeTransform
        eyeRNode.simdTransform = anchor.rightEyeTransform
        gazeNode.simdTransform = anchor.leftEyeTransform.average(with: anchor.rightEyeTransform)
        
        self.virtualScreenNode.simdTransform = frame.camera.transform
        
        // intersection of the ray with viewpoint plane
        // average gaze method
        let hitTestResults = self.virtualScreenNode.hitTestWithSegment(from: self.gazeTargetNode.worldPosition, to: self.gazeNode.worldPosition, options: nil)
        guard let hitTestCoordinates = hitTestResults.last?.localCoordinates else { return }
        
        var smoothPoint = self.mapToScreenCoordinates(CGPoint(x: CGFloat(hitTestCoordinates.x), y: CGFloat(hitTestCoordinates.y)))
        self.smoothingWindow.append(smoothPoint)
        
        // TODO: smoothing
//        if self.smoothingWindow.isFilled, let average = self.smoothingWindow.average {
//            smoothPoint = average
//        }
        
        // Calculate distance of the eyes to the camera
        let distance = (self.gazeNode.worldPosition - SCNVector3Zero).length()
        
        self.processBlendShapes(anchor.blendShapes, for: self.smoothingWindow, dist: distance)
        
        self.delegate?.tracker(
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
        
        if let leftProb = leftEyeBlinkProbability, leftProb.floatValue > self.leftEyeBlinkSensitivity {
            leftEyeBlinked = true
        }
        
        if let rightProb = rightEyeBlinkProbabiltity, rightProb.floatValue > self.rightEyeBlinkSensitivity {
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
        if self.blinkTimingOffset < window.contents.count {
            point = window.contents[window.contents.endIndex - self.blinkTimingOffset]
        }
        
        self.debouncer.debounce { [weak self] in
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
    
    private func mapToScreenCoordinates(_ point: CGPoint) -> CGPoint {
        switch UIDevice.current.orientation {
        case .portrait, .faceUp:
            return self.portraitCoordinateMapping(point)
        case .landscapeRight:
            return self.landscapeRightCoordinateMapping(point)
        case .portraitUpsideDown:
            return self.portraitUpsideDownCoordinateMapping(point)
        case .landscapeLeft:
            return self.landscapeLeftCoordinateMapping(point)
        default:
            return self.portraitCoordinateMapping(point)
        }
    }
    
    private func portraitCoordinateMapping(_ point: CGPoint) -> CGPoint {
        // transform hittest result to screen fraction
        let xPartial = point.x / (Device.current.realScreenSize.width / 2)
        let yPartial = point.y / (Device.current.realScreenSize.height / 2)

        let eyeLookAtPositionX = xPartial * Device.current.pointScreenSize.width + Device.current.pointScreenSize.width * Device.current.leadingFrontalCameraOffset
        let eyeLookAtPositionY = yPartial * Device.current.pointScreenSize.height

        return CGPoint(x: eyeLookAtPositionX, y: -eyeLookAtPositionY)
    }
    
    private func landscapeLeftCoordinateMapping(_ point: CGPoint) -> CGPoint {
        let xPartial = point.x / (Device.current.realScreenSize.height / 2)
        let yPartial = point.y / (Device.current.realScreenSize.width / 2)
        
        let eyeLookAtPositionX = xPartial * Device.current.pointScreenSize.width
        let eyeLookAtPositionY = yPartial * Device.current.pointScreenSize.height - Device.current.pointScreenSize.height * Device.current.leadingFrontalCameraOffset
        
        return CGPoint(x: eyeLookAtPositionX, y: -eyeLookAtPositionY)
    }
    
    private func landscapeRightCoordinateMapping(_ point: CGPoint) -> CGPoint {
        let xPartial = point.x / (Device.current.realScreenSize.height / 2)
        let yPartial = point.y / (Device.current.realScreenSize.width / 2)
        
        let eyeLookAtPositionX = xPartial * Device.current.pointScreenSize.width + Device.current.pointScreenSize.width
        let eyeLookAtPositionY = yPartial * Device.current.pointScreenSize.height - Device.current.pointScreenSize.height * (1 - Device.current.leadingFrontalCameraOffset)
        
        return CGPoint(x: eyeLookAtPositionX, y: -eyeLookAtPositionY)
    }
    
    private func portraitUpsideDownCoordinateMapping(_ point: CGPoint) -> CGPoint {
        // TODO: 
        // transform hittest result to screen fraction
        let xPartial = point.x / (Device.current.realScreenSize.width / 2)
        let yPartial = point.y / (Device.current.realScreenSize.height / 2)

        let eyeLookAtPositionX = xPartial * Device.current.pointScreenSize.width + (Device.current.pointScreenSize.width * 1 - Device.current.leadingFrontalCameraOffset)
        let eyeLookAtPositionY = yPartial * Device.current.pointScreenSize.height + Device.current.pointScreenSize.height

        return CGPoint(x: eyeLookAtPositionX, y: -eyeLookAtPositionY)
    }
}
