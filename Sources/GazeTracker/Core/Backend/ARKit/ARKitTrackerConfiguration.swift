//
//  ARKitTrackerConfiguration.swift
//  GazeTracker
//
//  Created by Enoxus on 02.05.2022.
//

import Foundation
import ARKit

public struct ARKitTrackerConfiguration {
    /// Determines the offset from the frame in which blink event was detected
    /// For example, if this value is 10, then blink event will use screen gaze position
    /// that was detected 10 frames ago.
    /// This allows to avoid downward gaze position shift caused by blinking
    public let blinkFrameOffset: Int
    /// Value between `0` and `1`. Determines the level of confidence when detecting blink event
    /// The smaller this value is, the less precise blink detection will be and thus
    /// more likely left eye blink will be detected in frame
    public let leftEyeBlinkThreshold: Float
    /// Value between `0` and `1`. Determines the level of confidence when detecting blink event
    /// The smaller this value is, the less precise blink detection will be and thus
    /// more likely right eye blink will be detected in frame
    public let rightEyeBlinkThreshold: Float
    /// Mapper that transforms point from metric to logic coordinate system. Defaults to `OrientationAwareCoordinateMapper`
    public let coordinateMapper: CoordinateMapper
    /// Optional scene view that will display internal scene contents. May be useful for debugging
    public let sceneView: ARSCNView?
    
    public init(
        blinkFrameOffset: Int = 9,
        leftEyeBlinkThreshold: Float = 0.5,
        rightEyeBlinkThreshold: Float = 0.5,
        coordinateMapper: CoordinateMapper = OrientationAwareCoordinateMapper(),
        sceneView: ARSCNView? = nil
    ) {
        self.blinkFrameOffset = blinkFrameOffset
        self.leftEyeBlinkThreshold = leftEyeBlinkThreshold
        self.rightEyeBlinkThreshold = rightEyeBlinkThreshold
        self.coordinateMapper = coordinateMapper
        self.sceneView = sceneView
    }
}
