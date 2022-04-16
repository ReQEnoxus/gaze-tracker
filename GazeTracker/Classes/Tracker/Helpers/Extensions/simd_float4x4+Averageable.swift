//
//  simd_float4x4+Averageable.swift
//  GazeTracker
//
//  Created by Enoxus on 09.01.2022.
//

import simd

extension simd_float4x4: Averageable {
    func average(with other: simd_float4x4) -> simd_float4x4 {
        return simd_mul(0.5, simd_add(self, other))
    }
}
