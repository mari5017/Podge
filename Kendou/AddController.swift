//
//  AddControllerViewController.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2023/12/10.
//

import UIKit
import AVFoundation

@available(iOS 17, *)
class AddController: UIViewController {
    
    @IBOutlet weak var playerview: PlayerView!
    @IBOutlet weak var slider: UISlider!
    var player = AVPlayer()
    var timeObserverToken: Any?
    var itemDuration: Double = 0
    var movieURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }
    
    private func setupPlayer() {
        playerview.player = player
        addPeriodicTimeObsever()
    }
    
    @IBAction func playerBtnTapped(_sender: Any){
        player.play()
    }
    
    @IBAction func pauseBtnTapped(_ sender: Any){
        player.pause()
    }
    
    @IBAction func selectvideo() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.videoExportPreset = AVAssetExportPresetHighestQuality
        present(picker,animated: true,completion: nil)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let seconds = Double(sender.value) * itemDuration
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: seconds, preferredTimescale: timeScale)
        changePosition(time: time)
    }
    
    private func changePosition(time: CMTime) {
        let rate = player.rate
        //いったんplayerを止める
        player.rate = 0
        //指定した場所へ移動
        player.seek(to: time,completionHandler: {_ in
            //playerを元のrateに戻す(0より大きいならrateの速度で再生される）
            self.player.rate = rate
        })
    }
    
    private func addPeriodicTimeObsever() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main)
        {[weak self] time in
            DispatchQueue.main.async {
                print("できたら表示")
                self?.updateSlider()
            }
        }
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    private func updateSlider() {
        let time = player.currentItem?.currentTime() ?? CMTime.zero
        if itemDuration != 0{
            slider.value = Float(CMTimeGetSeconds(time) / itemDuration)
        }
    }
    
    private func getSaveData() {
        guard let movieUrl = self.movieURL else{ return }
        Task{
            //replacePlayerItem
            do{
                self.movieURL = movieUrl
                let asset = AVAsset(url: self.movieURL)
                let duration = try await asset.load(.duration)
                itemDuration = CMTimeGetSeconds(duration)
                let item = AVPlayerItem(url: self.movieURL)
                
            }catch{
                print("error: \(error.localizedDescription)")
            }
        }
        
    }
    
    private func getPreviousCotroller() {
        let preTvc = self.presentingViewController as! UITabBarController
        let preNvc = preTvc.selectedViewController as! UINavigationController
        let vc = preNvc.viewControllers[0] as! VideoListController
        vc.fetchData()
    }
}

@available(iOS 17, *)
extension AddController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let movieUrl = info[.mediaURL] as? URL else { return }
        self.movieURL = movieUrl
        // replacePlayerItem
        let asset = AVAsset(url: movieUrl)
        itemDuration = CMTimeGetSeconds(asset.duration)
        let item = AVPlayerItem(url: movieUrl)
        player.replaceCurrentItem(with: item)
        
    }
    @available(iOS 17, *)
    @IBAction func saveButton(_sender: Any) {
        //アラートを出す
        AlertDialog.shared.showSaveWithTextAlert(vc:self) { text in
            //動画のファイルを移動させる！
            FileManagerService.shared.moveItem(sourceURL: self.movieURL)
            //サムネ用のスクリーンショットを撮る！
            let image = FileManagerService.shared.takeScreenshot(sourceURL: self.movieURL)
            guard let image = image else {return}
          //スクリーンショットを保存する！
            FileManagerService.shared.saveFile(file: image.jpegData(compressionQuality: 0.2)!,fileName: text)
            guard let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
                print("error: no directory")
                return
            }
            let myAppDirectory = docDirectory.appending(path: "MyAppContents")
            let imagePath = myAppDirectory.appending(path: "text")
            
            //タイトルなどを諸々保存する
            SwiftDataService.shared.saveVideo(videoPath: self.movieURL.lastPathComponent,imagePath: imagePath.lastPathComponent, title: "")
            //いったんコメントアウト: self.getPreviousController()
            self.getPreviousCotroller()
        }
    }
}
