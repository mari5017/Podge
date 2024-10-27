//
//  PlayerView.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2023/12/10.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player =  newValue }
    }
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer}
   
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    
}
