//
//  GazeTrackingBackendDelegate.swift
//  GazeTracker
//
//  Created by Enoxus on 08.03.2022.
//

import Foundation

public protocol GazeTrackingBackendDelegate: AnyObject {
    /// Notifies the delegate about new event
    func tracker(didEmit event: GazeTrackingEvent)
}
