//
//  SwiftDataService.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/01/28.
//

import Foundation
import SwiftData

//MARK: CRUD OPERATION
@available(iOS 17, *)
class SwiftDataService{
    static let shared = SwiftDataService()
    var container: ModelContainer?
    var context: ModelContext?
    
    init(){
        do{
            container = try ModelContainer(for: VideoModel.self)
            if let container{
                context = ModelContext(container)
            }
        }catch{
            
        }
    }
    //MARK: 動画を保存
    func saveVideo(videoPath: String, imagePath: String, title: String) {
        if let context{
            let savedVideo = VideoModel(id: UUID().uuidString, videoPath: videoPath, imagePath: imagePath, title: title,createdAt: Date(),memo: "")
            context.insert(savedVideo)
        }
    }
    //MARK: 動画を取得
    func fetchVideo(onCompletion: @escaping([VideoModel]?,Error?) -> Void){
        let descriptor = FetchDescriptor<VideoModel>(sortBy: [SortDescriptor<VideoModel>(\.createdAt)])
        if let context{
            do{
                let data = try context.fetch(descriptor)
                onCompletion(data,nil)
            }catch{
                onCompletion(nil, error)
            }
        }
    }
    //MARK: 動画をアップデート
    func updateVideo(videoModel: VideoModel, newTitle: String, newMemo: String){
        videoModel.title = newTitle
        videoModel.memo = newMemo
    }
    //MARK:　動画を削除
    func deleteVideo(videoModel: VideoModel){
        if let context{
            context.delete(videoModel)
        }
    }
}
