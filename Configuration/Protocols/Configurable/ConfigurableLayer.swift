//
//  ConfigurableLayer.swift
//  GazeTracker
//
//  Created by Enoxus on 03.05.2022.
//

import Foundation

/// Protocol that any configurable layer should conform to
public protocol ConfigurableLayerProtocol {
    associatedtype Configuration
    
    /// Allows adjusting tracker settings with `Configuration` object
    func configure(with configuration: Configuration)
}
