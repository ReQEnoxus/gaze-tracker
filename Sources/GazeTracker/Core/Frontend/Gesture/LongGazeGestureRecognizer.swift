//
//  LongGazeGestureRecognizer.swift
//  GazeTracker
//
//  Created by Enoxus on 08.05.2022.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

/// Discrete gesture recognizer that detects continous gaze event
open class LongGazeGestureRecognizer: BaseEyeGestureRecognizer {
    private enum State {
        case idle
        case tracking
    }
    
    /// Continous interval of gaze required for the gesture to be recognized
    public var gazeInterval: DispatchTimeInterval {
        get {
            return gazeDebouncer.interval
        }
        set {
            gazeDebouncer.interval = newValue
        }
    }
    /// If gaze event is not detected within this interval, the gesture is not considered as failed. Must be less than or equal to `gazeInterval`
    public var toleranceInterval: DispatchTimeInterval {
        get {
            return toleranceDebouncer.interval
        }
        set {
            if newValue <= gazeInterval {
                toleranceDebouncer.interval = newValue
            } else {
                toleranceDebouncer.interval = gazeInterval
            }
        }
    }
    
    private var detectionState: State = .idle
    private let gazeDebouncer = Debouncer(timeInterval: .milliseconds(100))
    private let toleranceDebouncer = Debouncer(timeInterval: .milliseconds(20))
    
    public override func processEvent(_ event: GazeEvent) {
        guard event.underlyingEvent.name == .gazePositionChanged else { return }
        switch detectionState {
        case .idle:
            detectionState = .tracking
            
            gazeDebouncer.debounce { [weak self] in
                self?.moveToRecognizedState()
            }
            
            toleranceDebouncer.debounce { [weak self] in
                self?.moveToFailedState()
            }
        case .tracking:
            toleranceDebouncer.debounce { [weak self] in
                self?.moveToFailedState()
            }
        }
    }
    
    open override func shouldReceive(_ event: UIEvent) -> Bool {
        return (event as? GazeEvent)?.underlyingEvent.name == .gazePositionChanged
    }
    
    private func moveToRecognizedState() {
        detectionState = .idle
        state = .recognized
        cancelPendingTasks()
    }
    
    private func moveToFailedState() {
        detectionState = .idle
        state = .failed
        cancelPendingTasks()
        
    }
    
    private func cancelPendingTasks() {
        gazeDebouncer.cancel()
        toleranceDebouncer.cancel()
    }
}

extension DispatchTimeInterval: Comparable {
    private var nanoseconds: Int {
        switch self {
        case .seconds(let seconds):
            return seconds * Int(1e9)
        case .microseconds(let microseconds):
            return microseconds * Int(1e6)
        case .milliseconds(let milliseconds):
            return milliseconds * Int(1e3)
        case .nanoseconds(let nanoseconds):
            return nanoseconds
        case .never:
            return .max
        }
    }
    
    public static func < (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> Bool {
        return lhs.nanoseconds < rhs.nanoseconds
    }
}
