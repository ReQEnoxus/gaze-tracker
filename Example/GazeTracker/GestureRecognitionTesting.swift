//
//  GestureRecognitionTesting.swift
//  GazeTracker_Example
//
//  Created by Enoxus on 09.05.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class GestureRecognizerTestViewController: UIViewController {
    private lazy var middleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("MIDDLE BUTTON", for: .normal)
        
        return button
    }()
    
    private var firstGestureRecognizer: UITapGestureRecognizer!
    private var secondGestureRecognizer: UITapGestureRecognizer!
    private var thirdGestureRecognizer: UITapGestureRecognizer!
    
    private var observers: [NSKeyValueObservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(middleButton)
        
        NSLayoutConstraint.activate(
            [
                middleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                middleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                middleButton.heightAnchor.constraint(equalToConstant: 90),
                middleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
        
        setupGestures()
    }
    
    private func setupGestures() {
        secondGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSecondGesture))
        middleButton.addGestureRecognizer(secondGestureRecognizer)
//        secondGestureRecognizer.numberOfTapsRequired = 2
        
        firstGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleFirstGesture))
//        firstGestureRecognizer.numberOfTapsRequired = 2
        middleButton.addGestureRecognizer(firstGestureRecognizer)
        
        thirdGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleThirdGesture))
//        thirdGestureRecognizer.numberOfTapsRequired = 3
        middleButton.addGestureRecognizer(thirdGestureRecognizer)
        
        [
            firstGestureRecognizer,
            secondGestureRecognizer,
            thirdGestureRecognizer
        ].forEach {
            observers.append(
                $0.observe(\UIGestureRecognizer.state, options: [.new], changeHandler: { [unowned self] recognizer, change in
                    let name: String
                    switch recognizer {
                    case self.firstGestureRecognizer:
                        name = "first"
                    case self.secondGestureRecognizer:
                        name = "second"
                    case self.thirdGestureRecognizer:
                        name = "third"
                    default:
                        name = ""
                    }
                    
                    print("log_\(name)GestureReognizerState = \(recognizer.state.rawValue)")
                })
            )
        }
        
        secondGestureRecognizer.delegate = self
        firstGestureRecognizer.delegate = self
        thirdGestureRecognizer.delegate = self
    }
    
    @objc private func handleFirstGesture(_ gestureRecognizer: UIGestureRecognizer) {
        print("log_firstGestureRecognizerFire, state = \(gestureRecognizer.state.rawValue)")
        animateViewIn(middleButton, type: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.animateViewOut(self.middleButton, type: 1)
        }
    }
    
    @objc private func handleSecondGesture(_ gestureRecognizer: UIGestureRecognizer) {
        print("log_secondGestureRecognizerFire, state = \(gestureRecognizer.state.rawValue)")
        animateViewIn(middleButton, type: 2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.animateViewOut(self.middleButton, type: 2)
        }
    }
    
    @objc private func handleThirdGesture(_ gestureRecognizer: UIGestureRecognizer) {
        print("log_secondGestureRecognizerFire, state = \(gestureRecognizer.state.rawValue)")
        animateViewIn(middleButton, type: 3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.animateViewOut(self.middleButton, type: 3)
        }
    }
    
    private func animateViewIn(_ view: UIView?, type: Int = 1) {
        guard let view = view else { return }
        
        UIView.animate(withDuration: 0.2) {
            if type == 1 {
                view.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                view.backgroundColor = .systemGreen
            } else if type == 2 {
                view.layer.cornerRadius = 30
            } else if type == 3 {
                view.alpha = 0.5
            }
        }
    }
    
    private func animateViewOut(_ view: UIView?, type: Int = 1) {
        guard let view = view else { return }
        
        UIView.animate(withDuration: 0.2) {
            if type == 1 {
                view.transform = .identity
                view.backgroundColor = .systemBlue
            } else if type == 2 {
                view.layer.cornerRadius = 8
            } else if type == 3 {
                view.alpha = 1
            }
        }
    }
}

extension GestureRecognizerTestViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        switch (gestureRecognizer, otherGestureRecognizer) {
        case (firstGestureRecognizer, secondGestureRecognizer):
            return true
        case (secondGestureRecognizer, thirdGestureRecognizer):
            return true
        case (thirdGestureRecognizer, secondGestureRecognizer):
            return true
        case (thirdGestureRecognizer, firstGestureRecognizer):
            return true
        default:
            return false
        }
    }
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        switch (gestureRecognizer, otherGestureRecognizer) {
//        case (firstGestureRecognizer, secondGestureRecognizer):
//            return true
//        case (firstGestureRecognizer, thirdGestureRecognizer):
//            return false
//        case (secondGestureRecognizer, thirdGestureRecognizer):
//            return true
//        default:
//            return false
//        }
//    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return otherGestureRecognizer == secondGestureRecognizer
//    }
}
