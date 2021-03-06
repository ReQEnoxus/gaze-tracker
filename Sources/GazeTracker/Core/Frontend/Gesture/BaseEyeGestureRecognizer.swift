//
//  BaseEyeGestureRecognizer.swift
//  GazeTracker
//
//  Created by Enoxus on 01.05.2022.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public protocol EyeTrackerGestureProtocol {
    func processEvent(_ event: GazeEvent)
}

open class BaseEyeGestureRecognizer: UIGestureRecognizer, EyeTrackerGestureProtocol {
    public func processEvent(_ event: GazeEvent) {
        guard isEnabled else { return }
        guard delegate?.gestureRecognizerShouldBegin?(self) != false else {
            state = .failed
            return
        }
    }
}

