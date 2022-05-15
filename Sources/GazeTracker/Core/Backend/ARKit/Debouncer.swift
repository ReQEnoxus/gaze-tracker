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
            workItem.cancel()
        }
    }
    
    private let queue = DispatchQueue.main
    private var workItem = DispatchWorkItem(block: {})
    
    init(timeInterval: DispatchTimeInterval = .milliseconds(50)) {
        interval = timeInterval
    }
    
    func debounce(_ action: @escaping (() -> Void)) {
        workItem.cancel()
        workItem = DispatchWorkItem(block: { action() })
        queue.asyncAfter(deadline: .now() + interval, execute: workItem)
    }
    
    func cancel() {
        workItem.cancel()
    }
}

