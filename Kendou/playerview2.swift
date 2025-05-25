//
//  playerview2.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2025/05/25.
//

import UIKit
import AVFoundation

class PlayerView2: UIView {
    override static var layerClass: AnyClass{AVPlayer.self}
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    private var playerLayer: AVPlayerLayer {layer as! AVPlayerLayer}
}



