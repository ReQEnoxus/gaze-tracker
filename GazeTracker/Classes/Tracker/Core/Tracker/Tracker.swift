//
//  Tracker.swift
//  GazeTracker
//
//  Created by Enoxus on 27.11.2021.
//

import ARKit
import SceneKit
import Foundation

let phoneScreenSize = CGSize(width: 1080 / 187.401575 / 100, height: 2340 / 187.401575 / 100) // iphone 12 mini for now

public class Tracker: NSObject {
    public var didUpdatePrediction: ((TrackingInfo) -> Void)?
    public let currentSession = ARSession()
    
    // MARK: - Scene
    
    public let scene = SCNScene()
    public var pointOfView: SCNNode?
    
    public var verticalSensitivity: Float = 1.0
    public var horizontalSensitivity: Float = 1.0
    
    // MARK: - Nodes
    
    private var faceNode: SCNNode = SCNNode()
    
    private let textureImage: UIImage
    
    public init(image: UIImage) {
        self.textureImage = image
    }
    
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
        screenGeometry.firstMaterial?.isDoubleSided = true
        screenGeometry.firstMaterial?.diffuse.contents = self.textureImage
        
        let superNode = SCNNode()
        let node = SCNNode(geometry: screenGeometry)

        
        superNode.addChildNode(node)
        
        superNode.opacity = 0.75
        
        return superNode
    }()
    
    private var lookAtTargetEyeLNode: SCNNode = SCNNode()
    private var lookAtTargetEyeRNode: SCNNode = SCNNode()
    
    private var gazeTargetNode: SCNNode = SCNNode()
    
    // MARK: - Cache
    
    private var smoothingWindow = SlidingAverageableWindow<CGPoint>(capacity: 30)
    
    // MARK: - Device Measurements
    
    // actual point size of iPhone screen
    private let phoneScreenPointSize = UIScreen.main.bounds.size
    
    public func startSession(scene: SCNScene? = nil) {
        guard ARFaceTrackingConfiguration.isSupported else {
            assertionFailure("Face tracking not supported on this device.")
            return
        }

        // Configure and start the ARSession to begin face tracking.
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1
        configuration.worldAlignment = .gravity
        
        self.setupSceneGraph(scene: scene)

        currentSession.delegate = self
        currentSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func setupSceneGraph(scene: SCNScene? = nil) {
        let scene = scene ?? self.scene
        let pointOfView = self.pointOfView ?? scene.rootNode
        let sphere = SCNSphere(radius: 0.10)
        sphere.firstMaterial?.diffuse.contents = UIColor.gray
        let sphereNode = SCNNode(geometry: sphere)
        pointOfView.addChildNode(sphereNode)
        scene.rootNode.addChildNode(faceNode)
        pointOfView.addChildNode(virtualPhoneNode)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(eyeLNode)
        faceNode.addChildNode(eyeRNode)
        faceNode.addChildNode(gazeNode)
        eyeLNode.addChildNode(lookAtTargetEyeLNode)
        eyeRNode.addChildNode(lookAtTargetEyeRNode)
        gazeNode.addChildNode(gazeTargetNode)
        
        lookAtTargetEyeLNode.position.z = 2
        lookAtTargetEyeRNode.position.z = 2
        gazeTargetNode.position.z = 1
    }
}

extension Tracker: ARSCNViewDelegate, ARSessionDelegate {
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let anchor = frame.anchors.first as? ARFaceAnchor else { return }
        faceNode.simdTransform = anchor.transform
        eyeLNode.simdTransform = anchor.leftEyeTransform
        eyeRNode.simdTransform = anchor.rightEyeTransform
        gazeNode.simdTransform = anchor.leftEyeTransform.average(with: anchor.rightEyeTransform)
        
        DispatchQueue.main.async {
            // intersection of the ray with viewpoint plane
            // average gaze method
            let hitTestResults = self.virtualScreenNode.hitTestWithSegment(from: self.gazeTargetNode.worldPosition, to: self.gazeNode.worldPosition, options: nil)
            guard let hitTestCoordinates = hitTestResults.last?.localCoordinates else { return }
            
            // individual gaze method
//            let leftHitTestResults = self.virtualScreenNode.hitTestWithSegment(from: self.eyeLNode.worldPosition, to: self.lookAtTargetEyeLNode.worldPosition, options: nil)
//            let rightHitTestResults = self.virtualScreenNode.hitTestWithSegment(from: self.eyeRNode.worldPosition, to: self.lookAtTargetEyeRNode.worldPosition, options: nil)
//            guard let leftHitTestCoordinates = leftHitTestResults.last?.localCoordinates,
//                  let rightHitTestCoordinates = rightHitTestResults.last?.localCoordinates else { return }
//            let hitTestCoordinates = leftHitTestCoordinates.average(with: rightHitTestCoordinates)
//            
            // transform hittest result to screen fraction
            let xPartial = CGFloat(hitTestCoordinates.x * self.horizontalSensitivity) / (phoneScreenSize.width / 2)
            let yPartial = CGFloat(hitTestCoordinates.y * self.verticalSensitivity) / (phoneScreenSize.height / 2)
            
            let eyeLookAtPositionX = xPartial * self.phoneScreenPointSize.width
            let eyeLookAtPositionY = yPartial * self.phoneScreenPointSize.height
            
            self.smoothingWindow.append(CGPoint(x: eyeLookAtPositionX, y: -eyeLookAtPositionY))
            
            guard self.smoothingWindow.isFilled,
                  let averagePoint = self.smoothingWindow.average else { return }
            
            // Calculate distance of the eyes to the camera
            let distance = (self.gazeNode.worldPosition - SCNVector3Zero).length()
            
            self.didUpdatePrediction?(
                TrackingInfo(
                    predictedPoint: averagePoint,
                    predictedDistance: distance
                )
            )
        }
    }
}
