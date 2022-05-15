//
//  SCNVector3+Averageable.swift
//  GazeTracker
//
//  Created by Enoxus on 09.01.2022.
//

import SceneKit

extension SCNVector3: Averageable {
    func average(with other: SCNVector3) -> SCNVector3 {
        return SCNVector3((x + other.x) / 2, (y + other.y) / 2, (z + other.z) / 2)
    }
}
