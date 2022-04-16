//
//  CGPoint+Averageable.swift
//  GazeTracker
//
//  Created by Enoxus on 09.01.2022.
//

import CoreGraphics

extension CGPoint: Averageable {
    func average(with other: CGPoint) -> CGPoint {
        return CGPoint(x: (self.x + other.x) / 2, y: (self.y + other.y) / 2)
    }
}
