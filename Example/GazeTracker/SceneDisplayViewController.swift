//
//  SceneDisplayViewController.swift
//  GazeTracker_Example
//
//  Created by Enoxus on 18.06.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import ARKit

final class SceneDisplayViewController: UIViewController {
    override func loadView() {
        let view = SceneDisplayView()
        view.automaticallyUpdatesLighting = true
        view.loops = true
        self.view = view
        self.view.layer.cornerRadius = 20
    }
}

final class SceneDisplayView: ARSCNView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view === self {
            return nil
        }
        
        return view
    }
}
