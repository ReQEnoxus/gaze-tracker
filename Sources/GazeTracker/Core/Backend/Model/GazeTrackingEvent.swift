//
//  GazeTrackingEvent.swift
//  GazeTracker
//
//  Created by Enoxus on 08.03.2022.
//

import Foundation
import CoreGraphics

public struct GazeTrackingEvent {
    public struct Name: Hashable {
        public let rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public let name: Name
    public let screenPoint: CGPoint
    public let screenDistance: Float
    public let userInfo: [AnyHashable: Any]?
    
    public init(
        name: Name,
        screenPoint: CGPoint,
        screenDistance: Float,
        userInfo: [AnyHashable: Any]? = nil
    ) {
        self.name = name
        self.screenPoint = screenPoint
        self.screenDistance = screenDistance
        self.userInfo = userInfo
    }
}

public extension GazeTrackingEvent.Name {
    /// Indicates gaze position prediction change
    static var gazePositionChanged = GazeTrackingEvent.Name("gazePositionChanged")
    /// Indicates left eye blink
    static var leftEyeBlink = GazeTrackingEvent.Name("leftEyeBlink")
    /// Indicates right eye blink
    static var rightEyeBlink = GazeTrackingEvent.Name("rightEyeBlink")
    /// Indicates simultaneous blink with both eyes
    static var bothEyesBlink = GazeTrackingEvent.Name("bothEyesBlink")
}
