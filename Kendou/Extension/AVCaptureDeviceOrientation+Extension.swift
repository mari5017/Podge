//
//  AVCaptureDeviceOrientation+Extension.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/06/09.
//

import Foundation
import UIKit
import AVFoundation

extension AVCaptureVideoOrientation {
    init(deviceOrientation: UIDeviceOrientation){
        switch deviceOrientation {
        case .landscapeLeft :
            self = .landscapeLeft
        case .landscapeRight :
            self = .landscapeRight
        case .portrait :
            self = .portrait
        case .portraitUpsideDown :
            self = .portraitUpsideDown
        default :
            self = .portrait
        }
    }
}
