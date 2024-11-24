//
//  VideoListController.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/01/28.
//

import UIKit
import SwiftData
import AVFoundation
import AVKit
import SwiftUI
@available(iOS 17,*)
class VideoListController: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    let fileManager = FileManagerService.shared
    public var videos = [VideoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        self.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchData()
    }
    //collectionViewの設定
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //レイアウトを調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        layout.itemSize = CGSize(width: 380, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collectionView.collectionViewLayout = layout
    }
   
    //データの取得のためのコード
    func fetchData() {
        SwiftDataService.shared.fetchVideo { data, error in
            if let error{
                print(error)
            }
            if let data{
                self.videos = data
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    //画像ファイルの読み込み
    private func convertToImage(Path: String) -> UIImage?{
        let data = FileManagerService.shared.readFile(fileName: Path)
        if let data{
            return UIImage(data: data)
        }else{
            return nil
        }
    }
    //TODO: 動画の再生
    private func playMovie(at url: URL){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let nextVC = storyboard.instantiateViewController(withIdentifier: "AddVC")as! AddController
          nextVC.movieURL = url
          let asset = AVAsset(url: url)
          nextVC.itemDuration = CMTimeGetSeconds(asset.duration)
          let item = AVPlayerItem(url: url)
          nextVC.player.replaceCurrentItem(with: item)
          self.present(nextVC, animated: true)
    }
    
    
}
@available(iOS 17,*)
extension VideoListController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK　表示するセルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    //MARK　セルのアウト決めと表示をする
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let image = convertToImage(Path: videos[indexPath.row].title)
        
        cell.contentConfiguration = UIHostingConfiguration(content: { MovieListCell(videoName: videos[indexPath.row].title, image: image)
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let videoUrl = FileManagerService.shared.getFileUrl(fileName: videos[indexPath.row].videoPath){
            self.playMovie(at: videoUrl)
        }
    }
   
}
