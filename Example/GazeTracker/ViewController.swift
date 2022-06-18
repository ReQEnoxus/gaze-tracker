//
//  ViewController.swift
//  GazeTracker
//
//  Created by ReQEnoxus on 11/27/2021.
//  Copyright (c) 2021 ReQEnoxus. All rights reserved.
//

import UIKit
import ARKit
import CenteredCollectionView

class ViewController: UIViewController {
    
    private enum Constants {
        enum Cell {
            static let heightMultiplier: CGFloat = 0.6
        }
        
        enum Button {
            static let height: CGFloat = 60
            static let verticalInset: CGFloat = 32
            static let horizontalInset: CGFloat = 24
        }
    }
    
    private var currentIndex: Int = 0 {
        didSet {
            topButton.isEnabled = currentIndex != .zero
            bottomButton.isEnabled = currentIndex != Video.mockData.count - 1
            collectionLayout.scrollToPage(index: currentIndex, animated: true)
        }
    }
    
    private lazy var collectionLayout: CenteredCollectionViewFlowLayout = {
        let layout = CenteredCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(
            width: view.bounds.width,
            height: view.bounds.height * Constants.Cell.heightMultiplier
        )
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(centeredCollectionViewFlowLayout: collectionLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor(red: 0.882, green: 0.89, blue: 0.914, alpha: 1)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var topButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Предыдущее видео", for: .normal)
        button.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        let blinkGesture = BlinkGestureRecognizer(target: self, action: #selector(handleTopButtonBlink))
        let gazeGesture = GazeGestureRecognizer(target: self, action: #selector(handleButtonGaze(gestureRecognizer:)))
        
        button.addGestureRecognizer(blinkGesture)
        button.addGestureRecognizer(gazeGesture)
        
        return button
    }()
    
    private lazy var bottomButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Следующее видео", for: .normal)
        button.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        let blinkGesture = BlinkGestureRecognizer(target: self, action: #selector(handleBottomButtonBlink))
        let gazeGesture = GazeGestureRecognizer(target: self, action: #selector(handleButtonGaze(gestureRecognizer:)))
        
        button.addGestureRecognizer(blinkGesture)
        button.addGestureRecognizer(gazeGesture)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupGesture()
        makeConstraints()
        setupCollectionView()
    }
    
    private func addSubviews() {
        view.addSubview(collectionView)
        view.addSubview(topButton)
        view.addSubview(bottomButton)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate(
            [
                topButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Button.horizontalInset),
                topButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Button.verticalInset),
                topButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Button.horizontalInset),
                topButton.heightAnchor.constraint(equalToConstant: Constants.Button.height),
                
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                bottomButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Button.horizontalInset),
                bottomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Button.verticalInset),
                bottomButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Button.horizontalInset),
                bottomButton.heightAnchor.constraint(equalToConstant: Constants.Button.height)
            ]
        )
    }
    
    private func setupGesture() {
        
    }
    
    private func setupCollectionView() {
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.description())
        collectionView.dataSource = self
    }
    
    @objc private func handleTopButtonBlink() {
        currentIndex -= 1
    }
    
    @objc private func handleBottomButtonBlink() {
        currentIndex += 1
    }
    
    @objc private func handleButtonGaze(gestureRecognizer: GazeGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            gestureRecognizer.view?.animateIn()
        case .ended:
            gestureRecognizer.view?.animateOut()
        default:
            break
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Video.mockData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.description(), for: indexPath) as! VideoCell
        cell.configure(with: Video.mockData[indexPath.item])
        cell.delegate = self
        
        return cell
    }
}

extension ViewController: VideoCellDelegate {
    func didDetectBlink(on video: Video) {
        let playerController = PlayerController(url: video.url)
        present(playerController, animated: true)
    }
}

