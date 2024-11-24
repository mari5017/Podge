//
//  VideoOutput.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/06/09.
//

import Foundation
import AVFoundation
import UIKit
import VideoToolbox

protocol VideoCaptureDelegate: AnyObject {
    func videoCapture(_videoCapture: VideoCapture ,didCaptureFrame image: CGImage?)
}

class VideoCapture: NSObject {
    //エラー
    enum VideoCaptureError: Error {
        case CaptureSessionIsMissing
        case invalidInput
        case invalidOutput
        case unknown
    }
    //デリゲート
    weak var delegate: VideoCaptureDelegate?
    //ビデオのキャプチャするためのフレームワーク
    let captureSession = AVCaptureSession()
    //動画出力に関するもの
    let videoOutput = AVCaptureVideoDataOutput()
    //カメラのポジション
    private(set) var cameraPosition = AVCaptureDevice.Position.back
    //キュー、スレッドに関して
    private let sessionQueue = DispatchQueue(label: "io.al03.pose-estimation-session-queue")
    
    //インプット
    private func setCaptureSessionInput() throws {
        guard let captureDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: AVMediaType.video,
            position: cameraPosition
        )else {
            throw VideoCaptureError.invalidInput
        }
        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }
        //Inputを作る
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            throw VideoCaptureError.invalidInput
        }
        guard captureSession.canAddInput(videoInput) else {
            throw VideoCaptureError.invalidInput
        }
        //Inputをセッションに追加する
        captureSession.addInput(videoInput)
    }
    //アウトプット
    private func setCaptureSessionOutput() throws {
        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        guard captureSession.canAddOutput(videoOutput) else {
            throw VideoCaptureError.invalidOutput
        }
        captureSession.addOutput(videoOutput)
        
        if let connection = videoOutput.connection(with: .video),
           connection.isVideoOrientationSupported {
            connection.videoOrientation = AVCaptureVideoOrientation(deviceOrientation: UIDevice.current.orientation)
            connection.isVideoMirrored = cameraPosition == .front
            if connection.videoOrientation == .landscapeLeft {
                connection.videoOrientation = .landscapeRight
            } else if connection.videoOrientation == .landscapeRight {
                connection.videoOrientation = .landscapeLeft
                
            }
        }
    }
    
    public func startCapturing(completion completionHandler: (() -> Void)? = nil) {
        sessionQueue.async {
            if !self.captureSession.isRunning{
                self.captureSession.startRunning()
            }
            if let completionHandler = completionHandler {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }
    
    public func stopCapturing(completion completionHandler: (() -> Void)? = nil) {
        sessionQueue.async {
            if self.captureSession.isRunning{
                self.captureSession.stopRunning()
            }
            if let completionHandler = completionHandler{
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }
    
    public func flipCamera(completion: @escaping(Error?) -> Void) {
        sessionQueue.async {
            do{
                self.cameraPosition = self.cameraPosition == .back ? .front : .back
                self.captureSession.beginConfiguration()
                
                try self.setCaptureSessionInput()
                try self.setCaptureSessionOutput()
                
                self.captureSession.commitConfiguration()
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    public func setUpAVCapture(completion: @escaping(Error?) -> Void) {
        sessionQueue.async {
            do {
                try self.setUpAVCapture()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    private func setUpAVCapture() throws {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .vga640x480
        try setCaptureSessionInput()
        try setCaptureSessionOutput()
        
        captureSession.commitConfiguration()
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        guard let delegate = delegate else { return }
        
        if let pixelBuffer = sampleBuffer.imageBuffer {
            guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess else { return }
            
            var image: CGImage?
            
            VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
            
            DispatchQueue.main.sync {
                delegate.videoCapture(_videoCapture: self, didCaptureFrame: image)
            }
        }
    }
}

