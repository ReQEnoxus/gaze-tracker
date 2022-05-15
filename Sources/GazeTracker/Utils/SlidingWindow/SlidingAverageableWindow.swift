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
            return storage
        }
    }
    
    var average: T? {
        get {
            return storage.average
        }
    }
    
    var isFilled: Bool {
        get {
            return storage.count == capacity
        }
    }
    
    init(capacity: Int) {
        self.capacity = capacity
        storage = [T]()
    }
    
    mutating func append(_ element: T) {
        if storage.count >= capacity {
            storage = Array(storage.dropFirst())
        }
        storage.append(element)
    }
}
