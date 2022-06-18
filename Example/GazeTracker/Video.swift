//
//  Video.swift
//  GazeTracker_Example
//
//  Created by Enoxus on 17.06.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

struct Video {
    let url: URL
    let title: String
    let subtitle: String
    let thumbnail: UIImage?
    
    static var mockData: [Video] = [
        Video(
            url: URL(Bundle.main.path(forResource: "1", ofType: "mp4"))!,
            title: "Частицы",
            subtitle: "Vivamus vestibulum ipsum sit amet erat bibendum egestas. Donec feugiat volutpat rutrum. In blandit, tellus quis dapibus sollicitudin, magna mi tempor arcu, in interdum nulla ipsum ac tellus. Pellentesque tempus, lacus ac commodo interdum, urna elit elementum orci, at egestas purus justo ut justo. Vestibulum maximus a urna ac euismod. Aenean nec enim tempus, maximus nulla dignissim, euismod ligula.",
            thumbnail: UIImage(named: "thumb1")
        ),
        Video(
            url: URL(Bundle.main.path(forResource: "2", ofType: "mp4"))!,
            title: "Планета",
            subtitle: "Phasellus in leo eros. Sed rhoncus faucibus ipsum a varius. Interdum et malesuada fames ac ante ipsum primis in faucibus. Nullam quis mi ac turpis commodo lobortis id vel lacus. Donec molestie vel ligula in congue. Nam interdum maximus imperdiet. Nullam suscipit, arcu at fringilla sollicitudin, mauris enim pharetra arcu, et posuere dui ante et libero. Morbi arcu est, auctor condimentum quam non, rutrum hendrerit urna. Ut eget ante consequat diam pulvinar congue.",
            thumbnail: UIImage(named: "thumb2")
        ),
        Video(
            url: URL(Bundle.main.path(forResource: "3", ofType: "mp4"))!,
            title: "Природа",
            subtitle: "Cras vehicula orci id maximus faucibus. Vestibulum dui purus, lobortis in rhoncus ut, posuere eget tellus. Pellentesque eu auctor velit. Suspendisse imperdiet, elit sed congue euismod, elit tortor efficitur neque, imperdiet venenatis eros erat sit amet mauris. Sed volutpat nisi in dui convallis, a viverra nisi commodo.",
            thumbnail: UIImage(named: "thumb3")
        )
    ]
}

private extension URL {
    init?(_ string: String?) {
        guard let string = string else { return nil }
        self.init(fileURLWithPath: string)
    }
}

