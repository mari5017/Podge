//
//  AddController + Etension.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2023/12/20.
//

import UIKit

class AddController___Etension: UIView {
    extension AddController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            dismiss(animated: true, completion: nil)
            guard let movieUrl = info[.mediaURL] as? URL else { return }
            
            // replacePlayerItem
            let asset = AVAsset(url: movieUrl)
            itemDuration = CMTimeGetSeconds(asset.duration)
            let item = AVPlayerItem(url: movieUrl)
            player.replaceCurrentItem(with: item)
            
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
