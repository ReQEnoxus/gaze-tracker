//
//  FrontendLayerProtocol.swift
//  GazeTracker
//
//  Created by Enoxus on 02.05.2022.
//

import Foundation

public typealias BackendLayerProtocol = OperationalBackendLayerProtocol & ConfigurableLayerProtocol

public protocol OperationalBackendLayerProtocol {
    
    init()
    
    /// Implementation should call delegate methods when it's ready to provide new data for frontend layer
    var delegate: GazeTrackingBackendDelegate? { get set }
    
    /// Begin tracking process
    func startTracking()
    
    /// End tracking process
    func endTracking()
}
