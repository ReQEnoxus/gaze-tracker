//
//  UIView+Extensions.swift
//  GazeTracker_Example
//
//  Created by Enoxus on 17.06.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

extension UIView {
    func animateIn() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
    }
}
