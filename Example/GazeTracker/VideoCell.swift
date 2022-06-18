//
//  VideoCell.swift
//  GazeTracker_Example
//
//  Created by Enoxus on 17.06.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

protocol VideoCellDelegate: AnyObject {
    func didDetectBlink(on video: Video)
}

final class VideoCell: UICollectionViewCell {
    
    private enum Constants {
        enum Container {
            static let padding: CGFloat = 32
        }
        
        enum ImageView {
            static let height: CGFloat = 220
        }
        
        enum TextLabel {
            static let verticalInset: CGFloat = 8
            static let horizontalInset: CGFloat = 16
            static let additionalVerticalInset: CGFloat = 24
        }
    }
    
    weak var delegate: VideoCellDelegate?
    
    private var videoModel: Video? {
        didSet {
            guard let model = videoModel else { return }
            titleLabel.text = model.title
            subtitleLabel.text = model.subtitle
            thumbnailImageView.image = model.thumbnail
        }
    }
    
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .thin)
        label.numberOfLines = .zero
        label.textColor = .systemGray2
        label.setContentHuggingPriority(.init(752), for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: Video) {
        videoModel = model
    }
    
    private func commonInit() {
        addSubviews()
        makeConstraints()
        setupGestureRecognizer()
    }
    
    private func addSubviews() {
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(thumbnailImageView)
        contentView.addSubview(containerView)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate(
            [
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Container.padding),
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Container.padding),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Container.padding),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Container.padding),
                
                thumbnailImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                thumbnailImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
                thumbnailImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                thumbnailImageView.heightAnchor.constraint(equalToConstant: Constants.ImageView.height),
                
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.TextLabel.horizontalInset),
                titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: Constants.TextLabel.verticalInset),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.TextLabel.horizontalInset),
                
                subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.TextLabel.horizontalInset),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.TextLabel.additionalVerticalInset),
                subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.TextLabel.horizontalInset),
                subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -Constants.TextLabel.verticalInset)
            ]
        )
    }
    
    private func setupGestureRecognizer() {
        let gazeGestureRecognizer = GazeGestureRecognizer(target: self, action: #selector(handleGaze(gestureRecognizer:)))
        let blinkGestureRecognizer = BlinkGestureRecognizer(target: self, action: #selector(handleBlink))
        
        gazeGestureRecognizer.delegate = self
        blinkGestureRecognizer.delegate = self
        
        containerView.addGestureRecognizer(gazeGestureRecognizer)
        containerView.addGestureRecognizer(blinkGestureRecognizer)
    }
    
    @objc private func handleGaze(gestureRecognizer: GazeGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            containerView.animateIn()
        case .ended:
            containerView.animateOut()
        default:
            break
        }
    }
    
    @objc private func handleBlink() {
        guard let videoModel = videoModel else { return }
        delegate?.didDetectBlink(on: videoModel)
    }
}

extension VideoCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
