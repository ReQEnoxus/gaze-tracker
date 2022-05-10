//
//  GazeEvent.swift
//  GazeTracker
//
//  Created by Enoxus on 09.05.2022.
//

import Foundation

/// `GazeTrackingEvent` wrapper for UIKit conformance
open class GazeEvent: UIEvent {
    
    let underlyingEvent: GazeTrackingEvent
    
    public init(underlyingEvent: GazeTrackingEvent) {
        self.underlyingEvent = underlyingEvent
        super.init()
    }
}
