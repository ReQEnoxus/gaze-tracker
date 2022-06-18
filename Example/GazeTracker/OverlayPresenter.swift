//
//  OverlayPresenter.swift
//  GazeTracker_Example
//
//  Created by Enoxus on 18.06.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

final class OverlayPresenter {
    enum Overlay: String {
        case pause = "pause.fill"
        case play = "play.fill"
        case forward = "goforward.10"
        case backward = "gobackward.10"
    }
    
    static let shared = OverlayPresenter()
    
    private var currentOverlay: UIImageView?
    
    func show(overlay: Overlay, in view: UIView?) {
        guard let view = view else { return }
        let config = UIImage.SymbolConfiguration(pointSize: 120, weight: .bold)
        let image = UIImage(systemName: overlay.rawValue, withConfiguration: config)
        currentOverlay?.removeFromSuperview()
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate(
            [
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
        
        currentOverlay = imageView
        
        UIView.animate(withDuration: 0.6) {
            imageView.alpha = 0
        } completion: { _ in
            imageView.removeFromSuperview()
            self.currentOverlay = nil
        }

    }
}
