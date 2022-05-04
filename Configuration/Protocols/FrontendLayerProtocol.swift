//
//  FrontendLayerProtocol.swift
//  GazeTracker
//
//  Created by Enoxus on 02.05.2022.
//

import Foundation

public typealias FrontendLayerProtocol = OperationalFrontendLayerProtocol & ConfigurableLayerProtocol

public protocol OperationalFrontendLayerProtocol: GazeTrackingBackendDelegate {
    init()
}
