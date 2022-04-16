//
//  Debouncer.swift
//  GazeTracker
//
//  Created by Enoxus on 20.03.2022.
//

import Foundation

protocol DebouncerProtocol {
    func debounce(_ action: @escaping (() -> Void))
}

class Debouncer: DebouncerProtocol {
    
    private let queue = DispatchQueue.main
    private var workItem = DispatchWorkItem(block: {})
    private var interval: DispatchTimeInterval
    
    init(timeInterval: DispatchTimeInterval = .milliseconds(50)) {
        self.interval = timeInterval
    }
    
    func debounce(_ action: @escaping (() -> Void)) {
        self.workItem.cancel()
        self.workItem = DispatchWorkItem(block: { action() })
        self.queue.asyncAfter(deadline: .now() + self.interval, execute: self.workItem)
    }
}

