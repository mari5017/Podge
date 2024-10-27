//
//  RecordingService.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/08/03.
//

import Foundation
import ReplayKit
import Photos

class RecordingService {
    static let shared = RecordingService()
    //レコーダー
    let recorder = RPScreenRecorder.shared()
    //レコードしたファイルのURLを入れる変数
    var url: URL?
    //スタート
    func startRecording() {
        guard recorder.isAvailable,!recorder.isRecording else { return }
        recorder.startRecording { error in
            print(error.debugDescription)
        }
    }
    //ストップ
    func stopRecording() async throws -> URL {
        let name = UUID().uuidString + ".mov"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try await recorder.stopRecording(withOutput: url)
        return url
    }
    
    
    //カメラロールに保存
    func saveMovieToCameraRoll() {
        guard let videoURL = self.url else {
            print("No video URL found.")
            return
        }
        PHPhotoLibrary.shared().performChanges {
            //ライブラリにビデオアセットを追加するためのリクエストを送る
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }completionHandler: { success, error in
            if success {
                print("Video saved to Camera Roll successfully.")
            } else {
                if let error = error{
                    print("Error saving video to Camera Roll: \(error.localizedDescription)")
                }
            }
        }
    }
}
