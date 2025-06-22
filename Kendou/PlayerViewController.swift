//
//  PlayerViewController.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2025/05/25.
//

import UIKit
import AVFoundation

@available(iOS 17, *)
class PlayerViewController: UIViewController {
    var scoreLabel: UILabel!
    @IBOutlet weak var playerview : PlayerView!
    @IBOutlet weak var slider: UISlider!
    var player = AVPlayer()
    var timeObserverToken: Any?
    var itemDuration: Double = 0
    var movieURL: URL!
    
    var addDelegate: AddDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    private func setupPlayer() {
        playerview.player = player
        addPeriodicTimeObsever()
    }
    @IBAction func playerBthTapped(_sender: Any) {
        player.play()
    }
    @IBAction func pauseBthTapped(_sender: Any) {
        player.pause()
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true,completion: nil)
    }
    @IBAction func sliderValueChanged(sender: UISlider) {
        let seconds = Double(sender.value) * itemDuration
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: seconds,preferredTimescale: timeScale)
        changePosition(time: time)
        
    }
    private func getPreviousCotroller() {
        let preTvc = self.presentingViewController as! UITabBarController
        let preNvc = preTvc.selectedViewController as! UINavigationController
        let vc = preNvc.viewControllers[0] as! VideoListController
        vc.fetchData()
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
    private func updateSlider() {
        let time = player.currentItem?.currentTime() ?? CMTime.zero
        if itemDuration != 0{
            slider.value = Float(CMTimeGetSeconds(time) / itemDuration)
        }
    }
    private func addPeriodicTimeObsever() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main)
        {[weak self] time in DispatchQueue.main.async{ print("おけー")
            self?.updateSlider()
        }
            
            
        }
        
        @available(iOS 17, *)
        
        func saveButton(_sender: Any) {
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
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
    
    protocol AddDelegate {
        func changePosition(time: CMTime)
    }
}
