//
//  PoseDetectionViewController.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/06/23.
//

import UIKit
import Vision
import ReplayKit
@available(iOS 17, *)
//TODO: PoseDetectionViewControllerの中に書く
class PoseDetectionViewController: UIViewController {
    let screenRecorder = RecordingService.shared
    let recorder = RPScreenRecorder.shared()
    var imageSize = CGSize.zero
    var posePattern: PosePattern = .none
    //表示するためのImageView
    @IBOutlet weak var previewImageview: UIImageView!
    private let videoCapture = VideoCapture()
    private var currentFrame: CGImage?
    
    //撮影したものを分析の保存用に使う
    var posewindows: [VNRecognizedPointsObservation?] = []
    //yoga
    let yogaClassifier = YogaAction()
    ////予測の精度に関わる数値
    var windowSize = 60
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAndBeginCapturingVideoFrames()
        posewindows.reserveCapacity(windowSize)
        
        if !recorder.isAvailable {
            recorder.accessibilityActivate()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        print("kikikikiki")
    }
    
    //カメラ関連のセットアップ
    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }
            self.videoCapture.delegate = self
            self.videoCapture.startCapturing()
            self.screenRecorder.startRecording()
        }
    }
    //画面が消えるときキャプチャを停止する
    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing(){
            super.viewWillDisappear(animated)
        }
    }
    //viewが切り終わったらセットアップする！
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setupAndBeginCapturingVideoFrames()
    }
    //カメラのボタン:関連付け
    @IBAction func onCameraButtonTapped(_ sender: Any) {
        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
            }
        }
    }
    
    //privateにする
    private func saveRecord() {
        Task { @MainActor in
            if recorder.isRecording {
                Task{
                    do{
                        self.screenRecorder.url = try await self.screenRecorder.stopRecording()
                        self.screenRecorder.saveMovieToCameraRoll()
                    } catch {
                        print(error)
                    }
                }
            } else {
                self.screenRecorder.startRecording()
            }
        }
    }
    //visionを使ったポーズ推定
    func estimation(_ cgImage:CGImage) {
        imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request:\(error).")
        }
    }
    //ポーズ検出の結果を処理する
    func bodyPoseHandler(request: VNRequest, error: Error?)  {
        guard let observations =
                request.results as? [VNRecognizedPointsObservation] else { return }
        if observations.count == 0 {
            guard let currentFrame = self.currentFrame else {
                return
            }
            let image = UIImage(cgImage: currentFrame)
            DispatchQueue.main.async {
                self.previewImageview.image = image
            }
        } else {
            let points = observations.map {(observation) -> [CGPoint] in
                let ps = processObservation(observation)
                return ps ?? []
            }
            let flatten = points.flatMap{$0}
            
            let image = currentFrame?.drawPoints(points: flatten)
            DispatchQueue.main.async {
                self.previewImageview.image = image
            }
        }
        poseClassifier(observations: observations, error: error)
    }
    
    //検出した人体のポーズのポイントについての処理
    func processObservation(_ observation: VNRecognizedPointsObservation) -> [CGPoint]? {
        guard let recognizedPoints =
                try? observation.recognizedPoints(forGroupKey: VNRecognizedPointGroupKey.all) else {
            return[]
        }
        let imagePoints: [CGPoint] = recognizedPoints.values.compactMap {
            guard $0.confidence > 0 else { return nil }
            return VNImagePointForNormalizedPoint($0.location, Int(imageSize.width), Int(imageSize.height))
        }
        return imagePoints
    }
    
    func poseClassifier(observations: [VNRecognizedPointsObservation], error: Error?) {
        //もし60フレームなかったら画像を追加する
        if posewindows.count < 60 {
            posewindows.append(contentsOf: observations)
        } else {
            do {
                // MLMultiArray: 機械学習をする際の入力に使われる形式に変換する
                let poseMultiArray: [MLMultiArray] = try posewindows.map { person in
                    guard let person = person else {
                        //人が検出されない場合
                        let zero: MLMultiArray = try! MLMultiArray(shape: [3, 100 ,100], dataType: .float)
                        return zero
                    }
                    //機械学習の＜特徴点＞を習得する
                    return try person.keypointsMultiArray()
                }
                //モデルに入力できるようにセット
                let modelInput = MLMultiArray(concatenating: poseMultiArray, axis: 0,dataType: .float)
                //モデルの予測
                let predictions = try yogaClassifier.prediction(poses: modelInput)
                
                //どんなポーズか
                print("pose: \(predictions.label)")
                //正確性は何％
                print("confience: \(predictions.labelProbabilities[predictions.label]!*100)")
                //判定して前画面に戻る
                let percentage = floor(predictions.labelProbabilities[predictions.label]!*10000)/100
                if percentage >= 80 && self.posePattern.rawValue == predictions.label {
                    SoundService.shared.playSound(filename: "OK", filetype: "mp3")
                    self.saveRecord()
                    DispatchQueue.main.async {
                        let preTVC = self.presentingViewController as! UITabBarController
                        let preVC = preTVC.selectedViewController as! PoseGachaViewController
                        preVC.percentage = percentage   //これがスコアだよ！
                        //ここで、前の画面に戻っている
                        //self.dismiss(animated: true)
                        //これを次の画面に遷移する
//                        let storyboard: UIStoryboard = self.storyboard!
//                        let nextView = storyboard.instantiateViewController(withIdentifier: "View") as! PlayerViewController
//                        self.present(nextView,animated: true ,completion: nil)
                        let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "View") as! PlayerViewController
                        self.present(playerViewController,animated: true,completion: nil)
                    }
                }
                
                //配列を初期化
                //初期化しないとずっと同じ画像がつまったままになる
                posewindows.removeFirst(windowSize)
            } catch {
                print(error)
            }
        }
    }
    
}
// MARK: - VideoCaptureDelegate
//Videoをキャプチャしたら推定する！
@available(iOS 17, *)
extension PoseDetectionViewController: VideoCaptureDelegate {
    func videoCapture(_videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }
        currentFrame = image
        estimation(image)
    }
}

