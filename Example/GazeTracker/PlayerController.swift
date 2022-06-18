//
//  PlayerController.swift
//  GazeTracker_Example
//
//  Created by Enoxus on 18.06.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import AVKit

final class PlayerController: AVPlayerViewController {
    
    private lazy var pauseGestureRecognizer: UIGestureRecognizer = {
        let gestureRecognizer = BlinkGestureRecognizer(target: self, action: #selector(handlePauseGesture))
        gestureRecognizer.blinkCount = 2
        gestureRecognizer.maximumBlinkInterval = .milliseconds(500)
        gestureRecognizer.name = "pauseGesture"
        gestureRecognizer.delegate = self
        
        return gestureRecognizer
    }()
    
    private lazy var exitGestureRecognizer: UIGestureRecognizer = {
        let gestureRecognizer = BlinkGestureRecognizer(target: self, action: #selector(handleExitGesture))
        gestureRecognizer.maximumBlinkInterval = .milliseconds(500)
        gestureRecognizer.name = "exitGesture"
        gestureRecognizer.blinkCount = 3
        
        return gestureRecognizer
    }()
    
    private lazy var skipBackwardGestureRecognizer: UIGestureRecognizer = {
        let gestureRecognizer = BlinkGestureRecognizer(target: self, action: #selector(handleBackwardSkipGesture))
        gestureRecognizer.blinkType = .leftEye
        
        return gestureRecognizer
    }()
    
    private lazy var skipForwardGestureRecognizer: UIGestureRecognizer = {
        let gestureRecognizer = BlinkGestureRecognizer(target: self, action: #selector(handleForwardSkipGesture))
        gestureRecognizer.blinkType = .rightEye
        
        return gestureRecognizer
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var isPaused = false
    private let seekLength: Float64 = 10
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        let player = AVPlayer(url: url)
        self.player = player
        showsPlaybackControls = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews.forEach { $0.isUserInteractionEnabled = false }
        addSubviews()
        makeConstraints()
        
        overlayView.addGestureRecognizer(pauseGestureRecognizer)
        overlayView.addGestureRecognizer(exitGestureRecognizer)
        overlayView.addGestureRecognizer(skipBackwardGestureRecognizer)
        overlayView.addGestureRecognizer(skipForwardGestureRecognizer)
        
        player?.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubviewToFront(overlayView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        view.addSubview(overlayView)
    }
    
    private func makeConstraints() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                overlayView.topAnchor.constraint(equalTo: view.topAnchor),
                overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
    
    @objc private func handlePauseGesture() {
        if isPaused {
            player?.play()
            OverlayPresenter.shared.show(overlay: .play, in: contentOverlayView)
        } else {
            player?.pause()
            OverlayPresenter.shared.show(overlay: .pause, in: contentOverlayView)
        }
        
        isPaused.toggle()
    }
    
    @objc private func handleExitGesture() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleForwardSkipGesture() {
        guard let player = player,
              let duration = player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + seekLength
        
        if newTime < CMTimeGetSeconds(duration) {
            OverlayPresenter.shared.show(overlay: .forward, in: contentOverlayView)
            let resultTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player.seek(to: resultTime)
        }
    }
    
    @objc private func handleBackwardSkipGesture() {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - seekLength
        
        if newTime < .zero {
            newTime = .zero
        }
        
        OverlayPresenter.shared.show(overlay: .backward, in: contentOverlayView)
        let resultTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player.seek(to: resultTime)
    }
}

extension PlayerController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == pauseGestureRecognizer && otherGestureRecognizer == exitGestureRecognizer
    }
}
