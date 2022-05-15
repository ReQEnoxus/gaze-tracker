//
//  GestureExecutionSystem.swift
//  GazeTracker
//
//  Created by Enoxus on 14.05.2022.
//

import UIKit
import Combine
import Collections

protocol GestureExecutionSystemDelegate: AnyObject {
    func didFinishExecuting(_ system: GestureExecutionSystem)
}

/// Class that orchestrates event delivery to gesture recognizers that may have dynamic failure requirements set up
class GestureExecutionSystem: Hashable {
    private class Dependencies: Hashable {
        static func == (lhs: GestureExecutionSystem.Dependencies, rhs: GestureExecutionSystem.Dependencies) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        var recognizers: OrderedSet<UIGestureRecognizer> {
            recognizerDependencies.keys
        }
        
        private var recognizerDependencies: OrderedDictionary<UIGestureRecognizer, Set<UIGestureRecognizer>>
        private let id = UUID()
        
        init(recognizers: [EyeGestureRecognizer]) {
            recognizerDependencies = [:]
            recognizers.forEach {
                recognizerDependencies[$0] = []
            }
            buildDependencyGraph(with: recognizers)
        }
        
        func of(_ recognizer: UIGestureRecognizer) -> Set<UIGestureRecognizer> {
            return recognizerDependencies[recognizer] ?? []
        }
        
        private func buildDependencyGraph(with recognizers: [EyeGestureRecognizer]) {
            recognizers.dropLast().enumerated().forEach { index, recognizer in
                recognizers.suffix(from: recognizers.index(recognizers.startIndex, offsetBy: index + 1)).forEach { otherRecognizer in
                    if recognizerDependsOn(recognizer, other: otherRecognizer) {
                        recognizerDependencies[recognizer]?.insert(otherRecognizer)
                    } else if recognizerDependsOn(otherRecognizer, other: recognizer) {
                        recognizerDependencies[otherRecognizer]?.insert(recognizer)
                    }
                }
            }
        }
        
        private func recognizerDependsOn(_ recognizer: UIGestureRecognizer, other: UIGestureRecognizer) -> Bool {
            guard !recognizerDependencies[other]!.contains(recognizer) else { return false }
            
            return recognizer.delegate?.gestureRecognizer?(recognizer, shouldRequireFailureOf: other) == true ||
            other.delegate?.gestureRecognizer?(other, shouldBeRequiredToFailBy: recognizer) == true ||
            recognizer.shouldRequireFailure(of: other) ||
            other.shouldBeRequiredToFail(by: recognizer)
        }
    }
    
    private weak var delegate: GestureExecutionSystemDelegate?
    private let dependencies: Dependencies
    private var cancellables: Set<AnyCancellable> = []
    private var visitedRecognizers: Set<UIGestureRecognizer> = [] {
        didSet {
            if visitedRecognizers.count == dependencies.recognizers.count {
                delegate?.didFinishExecuting(self)
            }
        }
    }
    private var firedRecognizers: Set<UIGestureRecognizer> = []
    
    private let id = UUID()
    
    init(eligibleRecognizers: [EyeGestureRecognizer], delegate: GestureExecutionSystemDelegate?) {
        self.delegate = delegate
        dependencies = Dependencies(recognizers: eligibleRecognizers)
    }
    
    func dispatch(event: GazeEvent) {
        dependencies.recognizers.filter { !dependencies.of($0).isEmpty }.forEach { recognizer in
            Publishers.ZipMany<UIGestureRecognizer.State, Never>(
                dependencies.of(recognizer).map { $0.publisher(for: \.state, options: [.new]).eraseToAnyPublisher() }
            ).sink { [weak self] states in
                guard let self = self else { return }
                if states.allSatisfy({ $0 == .failed }) {
                    self.tryPerformRecognition(of: event, on: recognizer as! EyeGestureRecognizer)
                } else if states.contains(where: { $0 == .recognized || $0 == .ended }) {
                    // dependencies are not satisfied
                    self.visitedRecognizers.insert(recognizer)
                }
            }.store(in: &cancellables)
        }
        
        dependencies.recognizers
            .filter { dependencies.of($0).isEmpty }
            .compactMap { $0 as? EyeGestureRecognizer }
            .forEach {
                tryPerformRecognition(of: event, on: $0)
            }
    }
    
    static func == (lhs: GestureExecutionSystem, rhs: GestureExecutionSystem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private func tryPerformRecognition(of event: GazeEvent, on recognizer: EyeGestureRecognizer) {
        
        if firedRecognizers.isEmpty {
            recognizer.processEvent(event)
            if recognizer.wasRecognized {
                firedRecognizers.insert(recognizer)
            }
        } else {
            var shouldBeRecognized = false
            firedRecognizers.forEach { otherRecognizer in
                if recognizer.delegate?.gestureRecognizer?(recognizer, shouldRecognizeSimultaneouslyWith: otherRecognizer) == true || otherRecognizer.delegate?.gestureRecognizer?(otherRecognizer, shouldRecognizeSimultaneouslyWith: recognizer) == true {
                    shouldBeRecognized = true
                    return
                }
            }
            if shouldBeRecognized {
                recognizer.processEvent(event)
                if recognizer.wasRecognized {
                    firedRecognizers.insert(recognizer)
                }
            }
        }
        visitedRecognizers.insert(recognizer)
    }
}

private extension UIGestureRecognizer {
    var wasRecognized: Bool {
        return [.began, .changed, .ended, .recognized].contains(state)
    }
}

