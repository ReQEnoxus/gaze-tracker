//
//  GazeGestureRecognizer.swift
//  GazeTracker
//
//  Created by Enoxus on 01.05.2022.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

open class GazeGestureRecognizer: EyeTrackerGestureRecognizer {
    
    private var currentEvent: GazeTrackingEvent?
    private let debouncer = Debouncer(timeInterval: .milliseconds(60))
    
    open override func processEvent(_ event: GazeTrackingEvent) {
        guard let view = view,
              let window = view.window else {
                  state = .failed
                  return
              }
        currentEvent = event
        let convertedPoint = view.convert(event.screenPoint, from: window)
        
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
}
