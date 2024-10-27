//
//  VideoMOdel.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/01/28.
//

import Foundation
import SwiftData

@available(iOS 17,*)
@Model
final class VideoModel{
    @Attribute(.unique) var id: String
    var videoPath: String
    var imagePath: String
    var title: String
    var memo: String
    var createdAt: Date
    
    init(id: String, videoPath: String, imagePath: String,title:String, createdAt: Date, memo:String){
        self.id = id
        self.videoPath = videoPath
        self.imagePath = imagePath
        self.title = title
        self.createdAt = createdAt
        self.memo = memo
    }
}

