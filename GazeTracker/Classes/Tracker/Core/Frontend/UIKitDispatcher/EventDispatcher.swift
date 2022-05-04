//
//  EventDispatcher.swift
//  GazeTracker
//
//  Created by Enoxus on 01.05.2022.
//

import Foundation

open class EventDispatcher: FrontendLayerProtocol {
    private var rootWindow: UIWindow?
    
    private var pointerView: UIView = {
        let view = UIView(frame: .init(origin: .zero, size: CGSize(width: 10, height: 10)))
        view.backgroundColor = .red
        view.layer.cornerRadius = 5
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    private var configuration: EventDispatcherConfiguration = .init()
    
    required public init() {}
    
    public func configure(with configuration: EventDispatcherConfiguration) {
        switch configuration.windowDetectionMethod {
        case .manual(let window):
            rootWindow = window
        case .automatic:
            rootWindow = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first
        }
        
        if configuration.displayGazeLocation {
            pointerView.removeFromSuperview()
            rootWindow?.addSubview(pointerView)
            rootWindow?.bringSubview(toFront: pointerView)
        } else {
            pointerView.removeFromSuperview()
        }
        
        self.configuration = configuration
    }
}

extension EventDispatcher: GazeTrackingBackendDelegate {
    open func tracker(didEmit event: GazeTrackingEvent) {
        let viewCandidate = rootWindow?.hitTest(event.screenPoint, with: nil)
        viewCandidate?.gestureRecognizers?
            .compactMap { $0 as? EyeTrackerGestureProtocol }
            .forEach { $0.processEvent(event) }
        
        if self.configuration.displayGazeLocation {
            rootWindow?.bringSubview(toFront: pointerView)
            pointerView.center = event.screenPoint
        }
    }
}
