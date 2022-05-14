//
//  EventDispatcher.swift
//  GazeTracker
//
//  Created by Enoxus on 01.05.2022.
//

import Foundation
import UIKit

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
    
    open func getView(for event: GazeEvent) -> UIView? {
        return rootWindow?.hitTest(event.underlyingEvent.screenPoint, with: event)
    }
    
    open func getEligibleGestureRecognizers(for view: UIView?, event: GazeEvent) -> [EyeTrackerGestureProtocol] {
        guard let gestureRecognizers = view?.gestureRecognizers?.compactMap({ $0 as? (EyeTrackerGestureProtocol & UIGestureRecognizer) }) else { return [] }

        var eligibleGestures: [UIGestureRecognizer] = []
        var unvisited: Set<UIGestureRecognizer> = Set(gestureRecognizers)
        
        // find the first (actually, last, to match UIKit logic for regular gestures) gesture recognizer that will process given event
        
        if let firstRecognizer = gestureRecognizers.last(where: { $0.shouldReceive(event) }) {
            eligibleGestures.append(firstRecognizer)
            unvisited.remove(firstRecognizer)
        } else {
            // if no gesture is willing to consume event, there is no need to dispatch it further
            return []
        }
        
        // now we need to determine which gesture recognizers also need to get this event according to delegate setup
        
        // for each of currently found eligible recognizers (it's just one at this point), check every unvisited gesture and, if their delegate setup suggests simultaneous recognition, add them to the list of eligible gesture recognizers. Time complexity - O(n^2)
        var index = Int.zero
        while index < eligibleGestures.count {
            unvisited.forEach { recognizer in
                if eligibleGestures[index].delegate?.gestureRecognizer?(eligibleGestures[index], shouldRecognizeSimultaneouslyWith: recognizer) == true ||
                    recognizer.delegate?.gestureRecognizer?(recognizer, shouldRecognizeSimultaneouslyWith: eligibleGestures[index]) == true {
                    eligibleGestures.append(recognizer)
                    unvisited.remove(recognizer)
                }
            }
            index += 1
        }

        return eligibleGestures.compactMap { $0 as? EyeTrackerGestureProtocol }
    }
}

extension EventDispatcher: GazeTrackingBackendDelegate {
    open func tracker(didEmit event: GazeTrackingEvent) {
        let gazeEvent = GazeEvent(underlyingEvent: event)
        let viewCandidate = getView(for: gazeEvent)
        getEligibleGestureRecognizers(for: viewCandidate, event: gazeEvent)
            .forEach { $0.processEvent(gazeEvent) }
        
        if configuration.displayGazeLocation {
            rootWindow?.bringSubview(toFront: pointerView)
            pointerView.center = event.screenPoint
        }
    }
}
