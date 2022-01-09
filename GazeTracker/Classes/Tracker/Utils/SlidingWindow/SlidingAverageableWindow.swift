//
//  SlidingWindow.swift
//  GazeTracker
//
//  Created by Enoxus on 09.01.2022.
//

import Foundation

struct SlidingAverageableWindow<T: Averageable> {
    let capacity: Int
    
    private var storage: [T]
    
    var contents: [T] {
        get {
            return self.storage
        }
    }
    
    var average: T? {
        get {
            return self.storage.average
        }
    }
    
    var isFilled: Bool {
        get {
            return self.storage.count == self.capacity
        }
    }
    
    init(capacity: Int) {
        self.capacity = capacity
        self.storage = [T]()
    }
    
    mutating func append(_ element: T) {
        if self.storage.count >= self.capacity {
            self.storage = Array(self.storage.dropFirst())
        }
        self.storage.append(element)
    }
}
