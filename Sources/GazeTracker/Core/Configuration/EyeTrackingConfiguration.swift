//
//  EyeTrackingConfiguration.swift
//  GazeTracker
//
//  Created by Enoxus on 02.05.2022.
//

import Foundation

public struct EyeTrackingConfiguration<Backend: BackendLayerProtocol, Frontend: FrontendLayerProtocol> {
    public class Builder<B: BackendLayerProtocol, F: FrontendLayerProtocol> {
        var backendLayer: B?
        var backendConfig: B.Configuration?
        var frontendLayer: F?
        var frontendConfig: F.Configuration?
        
        public func backend(config: B.Configuration) -> Self {
            backendLayer = B.init()
            backendConfig = config
            
            return self
        }
        
        public func frontend(config: F.Configuration) -> Self {
            frontendLayer = F.init()
            frontendConfig = config
            
            return self
        }
        
        public func build() -> EyeTrackingConfiguration<B, F> {
            guard let backendConfig = backendConfig,
                  let frontendConfig = frontendConfig,
                  let backend = backendLayer,
                  let frontend = frontendLayer else {
                      fatalError("Eye tracking was not configured properly. Backend config: \(String(describing: backendConfig)), Frontend config: \(String(describing: frontendConfig))")
                  }
            backend.configure(with: backendConfig)
            frontend.configure(with: frontendConfig)
            
            return EyeTrackingConfiguration<B, F>(
                backend: backend,
                frontend: frontend
            )
        }
    }
    
    public static func builder() -> Builder<Backend, Frontend> {
        return Builder()
    }
    
    let backend: Backend
    let frontend: Frontend
}
