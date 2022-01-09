//
//  TrackingInfo.swift
//  GazeTracker
//
//  Created by Enoxus on 05.12.2021.
//

import Foundation

public struct TrackingInfo {
    public let predictedPoint: CGPoint
    public let predictedDistance: Float
    
    public init(predictedPoint: CGPoint, predictedDistance: Float) {
        self.predictedPoint = predictedPoint
        self.predictedDistance = predictedDistance
    }
}
