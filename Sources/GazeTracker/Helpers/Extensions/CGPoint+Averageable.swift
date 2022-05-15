//
//  CGPoint+Averageable.swift
//  GazeTracker
//
//  Created by Enoxus on 09.01.2022.
//

import CoreGraphics

extension CGPoint: Averageable {
    func average(with other: CGPoint) -> CGPoint {
        return CGPoint(x: (x + other.x) / 2, y: (y + other.y) / 2)
    }
}
