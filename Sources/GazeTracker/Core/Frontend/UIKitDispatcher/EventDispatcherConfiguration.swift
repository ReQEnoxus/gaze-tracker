//
//  EventDispatcherConfiguration.swift
//  GazeTracker
//
//  Created by Enoxus on 02.05.2022.
//

import UIKit

public struct EventDispatcherConfiguration {
    public enum WindowDetectionMethod {
        /// Event dispatcher will determine root window automatically
        case automatic
        /// Event dispatcher will use provided window as root for hit-testing
        case manual(UIWindow?)
    }
    
    public let windowDetectionMethod: WindowDetectionMethod
    public let displayGazeLocation: Bool
    
    public init(
        windowDetectionMethod: WindowDetectionMethod = .automatic,
        displayGazeLocation: Bool = false
    ) {
        self.windowDetectionMethod = windowDetectionMethod
        self.displayGazeLocation = displayGazeLocation
    }
}
