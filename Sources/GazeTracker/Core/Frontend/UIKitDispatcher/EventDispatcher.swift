//
//  EventDispatcher.swift
//  GazeTracker
//
//  Created by Enoxus on 01.05.2022.
//

import Foundation
import UIKit

public typealias EyeGestureRecognizer = UIGestureRecognizer & EyeTrackerGestureProtocol

open class EventDispatcher: FrontendLayerProtocol {
    private var rootWindow: UIWindow?
    private var executionSystems: Set<GestureExecutionSystem> = []
    
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
            rootWindow?.bringSubviewToFront(pointerView)
        } else {
            pointerView.removeFromSuperview()
        }
        
        self.configuration = configuration
    }
    
    open func getView(for event: GazeEvent) -> UIView? {
        return rootWindow?.hitTest(event.underlyingEvent.screenPoint, with: event)
    }
    
    open func getEligibleGestureRecognizers(for view: UIView?, event: GazeEvent) -> [EyeGestureRecognizer] {
        // Getting all recognizers from current view
        var gestureRecognizers = view?.gestureRecognizers?.compactMap({ $0 as? EyeGestureRecognizer }) ?? []
        
        // Getting all recognizers from view hierarchy
        var currentView = view
        while let superView = currentView?.superview {
            gestureRecognizers.append(
                contentsOf: superView.gestureRecognizers?.compactMap({ $0 as? EyeGestureRecognizer }) ?? []
            )
            currentView = currentView?.superview
        }
        
        // Finally, getting all recognizers from window
        gestureRecognizers.append(
            contentsOf: rootWindow?.gestureRecognizers?.compactMap({ $0 as? EyeGestureRecognizer }) ?? []
        )
        // Return reversed recognizers list to match UIKit logic
        return gestureRecognizers.reversed().filter { $0.shouldReceive(event) }
    }
}

extension EventDispatcher: GazeTrackingBackendDelegate {
    open func tracker(didEmit event: GazeTrackingEvent) {
        let gazeEvent = GazeEvent(underlyingEvent: event)
        let viewCandidate = getView(for: gazeEvent)
        let gestureRecognizers = getEligibleGestureRecognizers(for: viewCandidate, event: gazeEvent)
        let system = GestureExecutionSystem(eligibleRecognizers: gestureRecognizers, delegate: self)
        executionSystems.insert(system)
        system.dispatch(event: gazeEvent)
        
        if configuration.displayGazeLocation {
            rootWindow?.bringSubviewToFront(pointerView)
            pointerView.center = event.screenPoint
        }
    }
}

extension EventDispatcher: GestureExecutionSystemDelegate {
    func didFinishExecuting(_ system: GestureExecutionSystem) {
        executionSystems.remove(system)
    }
}
