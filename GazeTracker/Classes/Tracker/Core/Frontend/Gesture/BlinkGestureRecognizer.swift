//
//  BlinkGestureRecognizer.swift
//  GazeTracker
//
//  Created by Enoxus on 01.05.2022.
//

import Foundation

/// Discrete gesture recognizer that detects a certain number of blinks
open class BlinkGestureRecognizer: EyeTrackerGestureRecognizer {
    public enum BlinkType {
        case leftEye
        case rightEye
        case bothEyes
    }
    
    public var blinkType: BlinkType = .bothEyes
    public var blinkCount: Int = 1
    
    public var maximumBlinkInterval: DispatchTimeInterval {
        get {
            return debouncer.interval
        }
        set {
            debouncer.interval = newValue
        }
    }
    
    private var currentBlinkCount = 0
    private var debouncer = Debouncer()
    
    public override func processEvent(_ event: GazeTrackingEvent) {
        let expectedEvent: GazeTrackingEvent.Name
        
        switch blinkType {
        case .leftEye:
            expectedEvent = .leftEyeBlink
        case .rightEye:
            expectedEvent = .rightEyeBlink
        case .bothEyes:
            expectedEvent = .bothEyesBlink
        }
        
        if event.name == expectedEvent {
            currentBlinkCount += 1
            if currentBlinkCount == blinkCount {
                state = .recognized
            } else {
                debouncer.debounce { [weak self] in
                    self?.state = .failed
                }
            }
        }
    }
    
    open override func reset() {
        super.reset()
        currentBlinkCount = 0
    }
}
