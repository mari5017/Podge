//
//  FileManager.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/01/14.
//

import Foundation
import AVFoundation
import UIKit

@available(iOS 17,*)
class FileManagerService {
    static let shared = FileManagerService()
    let fileManager = FileManager.default
    //MARK: フォルダーを作る
    public func createFolder() {
        guard let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("error: no directory")
            return
        }
        let myAppDirectory = docDirectory.appending(path: "MyAppContents",directoryHint: .isDirectory)
        do {
            try fileManager.createDirectory(at: myAppDirectory, withIntermediateDirectories: true)
        }catch{
            print("Failed Creating Folder: \(error.localizedDescription)")
        }
    }
    //MARK: ファイルの保存
    public func saveFile(file:Data,fileName: String) {
        guard let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            print("error: no directory")
            return
        }
        let myAppDirectory = docDirectory.appending(path: "MyAppContents")
        let fullPath = myAppDirectory.appending(path: fileName)
        do{
            try file.write(to: fullPath)
        }catch{
            print("error: no directory")
        }
    }
    
    //MARK: ファイルの移動
    public func moveItem(sourceURL: URL) {
        do{
            guard let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
                print("error no directory")
                return
            }
            let myAppDirectory = docDirectory.appending(path: "MyAppContents")
            //ディレクトリが存在しない場合は作成する
            if !fileManager.fileExists(atPath: myAppDirectory.path){
                try fileManager.createDirectory(at: myAppDirectory, withIntermediateDirectories: true,attributes: nil)
                
            }
            let fullPath = myAppDirectory.appending(path: sourceURL.lastPathComponent)
            self.exportMovie(sourceURL: sourceURL, destinationURL:fullPath, fileType:AVFileType.mov)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    //MARK: ファイルの読み込み
    public func readFile(fileName: String) -> Data? {
        guard let docDirectory = FileManager.default.urls(for:  .documentDirectory, in: .userDomainMask).first else{
            print("error no directory")
            return nil
        }
        let myAppDirectory = docDirectory.appending(path: "MyAppContents")
        let fullPath = myAppDirectory.appending(path: fileName)
        
        do{
            let fileContents = try Data(contentsOf: fullPath)
            return fileContents
        }catch{
            print("error: \(error.localizedDescription)")
        }
        return nil
    }
    
    //MARK: EXPORT
    func exportMovie(sourceURL:URL,destinationURL: URL,fileType:AVFileType) -> Void {
        Task{
            let avAsset:AVAsset = AVAsset(url: sourceURL)
            let videoTrack: AVAssetTrack = try await avAsset.loadTracks(withMediaType: AVMediaType.video)[0]
            let audioTracks: [AVAssetTrack] = try await avAsset.loadTracks(withMediaType: AVMediaType.audio)
            let audioTrack: AVAssetTrack? = audioTracks.count > 0 ? audioTracks[0] : nil
            
            let mainComposition : AVMutableComposition = AVMutableComposition()
            
            //videoとaudioのコンポジショントラックをそれぞれ作成
            let compositionVideoTrack: AVMutableCompositionTrack = mainComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!
            let compositionAudioTrack: AVMutableCompositionTrack? = audioTrack != nil
            ? mainComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID:kCMPersistentTrackID_Invalid)!
            : nil
            //コンポジションの設定
            try! compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: try await avAsset.load(.duration)), of: videoTrack, at: CMTime.zero)
            try! compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: try await avAsset.load(.duration)), of: audioTrack!, at: CMTime.zero)
            //エクスポートするためのセッションを作成
            let assetExport = AVAssetExportSession.init(asset: mainComposition, presetName: AVAssetExportPresetMediumQuality)
            //エクスポートするファイルの種類を設定
            assetExport?.outputFileType = fileType
            //エクスポート先URLを設定
            assetExport?.outputURL = destinationURL
            //エクスポート先URLに既にファイルが存在していれば、削除する
            if FileManager.default.fileExists(atPath: (assetExport?.outputURL?.path)!){
                try! FileManager.default.removeItem(atPath: (assetExport?.outputURL?.path)!)
            }
            await assetExport?.export()
        }
    }
    
    //MARK: スクリーンショットを撮る
    public func takeScreenshot(sourceURL: URL) -> UIImage? {
        let capturingTime: CMTime = CMTimeMakeWithSeconds(Float64(0), preferredTimescale: 1)
        let asset: AVAsset = AVURLAsset(url: sourceURL,options: nil)
        let imageGenerator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        let image = try!imageGenerator.copyCGImage(at: capturingTime, actualTime: nil)
        return UIImage(cgImage: image)
    }
    
    public func getFileUrl(fileName: String)-> URL? {
        guard let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("error: no directory")
            return nil
        }
        let myAddDirectory = docDirectory.appending(path: "MyAppContents")
        let fullPath = myAddDirectory.appending(path: fileName)
        return fullPath
    }
    
}
