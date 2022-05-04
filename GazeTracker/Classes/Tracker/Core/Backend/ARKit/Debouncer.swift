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
    
    var interval: DispatchTimeInterval {
        didSet {
            self.workItem.cancel()
        }
    }
    
    private let queue = DispatchQueue.main
    private var workItem = DispatchWorkItem(block: {})
    
    init(timeInterval: DispatchTimeInterval = .milliseconds(50)) {
        self.interval = timeInterval
    }
    
    func debounce(_ action: @escaping (() -> Void)) {
        self.workItem.cancel()
        self.workItem = DispatchWorkItem(block: { action() })
        self.queue.asyncAfter(deadline: .now() + self.interval, execute: self.workItem)
    }
    
    func cancel() {
        self.workItem.cancel()
    }
}

