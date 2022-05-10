//
//  EyeTrackingSystem.swift
//  GazeTracker
//
//  Created by Enoxus on 02.05.2022.
//

import Foundation

public class EyeTrackingSystem {
    private static let shared = EyeTrackingSystem()
    
    private var backend: OperationalBackendLayerProtocol?
    private var frontend: OperationalFrontendLayerProtocol?
    
    public static func initializeWidthDefaultConfiguration() {
        let config = EyeTrackingConfiguration<ARKitTracker, EventDispatcher>
            .builder()
            .backend(config: .init())
            .frontend(config: .init())
            .build()
        
        shared.backend = config.backend
        shared.frontend = config.frontend
        shared.backend?.delegate = config.frontend
    }
    
    public static func initializeWithCustomConfiguration<B: BackendLayerProtocol, F: FrontendLayerProtocol>(_ configuration: EyeTrackingConfiguration<B, F>) {
        
        shared.backend = configuration.backend
        shared.frontend = configuration.frontend
        shared.backend?.delegate = configuration.frontend
    }
    
    public static func startTracking() {
        shared.backend?.startTracking()
    }
    
    public static func endTracking() {
        shared.backend?.endTracking()
    }
}
