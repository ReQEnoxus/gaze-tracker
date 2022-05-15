//
//  GazeGestureRecognizer.swift
//  GazeTracker
//
//  Created by Enoxus on 01.05.2022.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

/// Continous gesture recognizer that detects gaze position change
open class GazeGestureRecognizer: BaseEyeGestureRecognizer {
    
    private var currentEvent: GazeTrackingEvent?
    private let debouncer = Debouncer(timeInterval: .milliseconds(60))
    
    open override func processEvent(_ event: GazeEvent) {
        guard let view = view,
              let window = view.window else {
                  state = .failed
                  return
              }
        guard event.underlyingEvent.name == .gazePositionChanged else { return }
        currentEvent = event.underlyingEvent
        let convertedPoint = view.convert(event.underlyingEvent.screenPoint, from: window)
        
        if view.bounds.contains(convertedPoint) {
            if state == .began {
                state = .changed
            } else {
                state = .began
            }
            debouncer.debounce { [weak self] in
                self?.state = .ended
            }
        } else {
            if state == .began || state == .changed {
                state = .ended
            } else {
                state = .failed
            }
        }
    }
    
    open override func location(in view: UIView?) -> CGPoint {
        guard let view = view,
              let window = view.window,
              let currentEvent = currentEvent else { return .zero }
        
        return view.convert(currentEvent.screenPoint, from: window)
    }
    
    open override func shouldReceive(_ event: UIEvent) -> Bool {
        return (event as? GazeEvent)?.underlyingEvent.name == .gazePositionChanged
    }
}
