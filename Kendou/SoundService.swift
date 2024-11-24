//
//  RecordingService.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/11/19.
//

import Foundation
import AVFoundation

class SoundService {
    static let shared = SoundService()
    
    var audioPlayer: AVAudioPlayer?
    
    func playSound(filename: String, filetype: String) {
        if let path = Bundle.main.path(forResource: filename, ofType: filetype){
            let url = URL(fileURLWithPath: path)
            do{
                audioPlayer = try AVAudioPlayer(contentsOf:url)
                audioPlayer?.play()
            }catch{
                print("音楽ファイルの再生に失敗しました")
            }
        }
            
    }
}
