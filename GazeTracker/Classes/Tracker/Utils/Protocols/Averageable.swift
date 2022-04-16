//
//  Averageable.swift
//  GazeTracker
//
//  Created by Enoxus on 09.01.2022.
//

import Foundation

protocol Averageable {
    func average(with other: Self) -> Self
}

extension Collection where Element: Averageable {
    var average: Element? {
        return self.reduce(self.first) { partialResult, next in
            return partialResult?.average(with: next)
        }
    }
}
