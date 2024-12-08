//
//  AlertUtil.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/01/28.
//

import Foundation
import UIKit
struct AlertDialog {
    static let shared = AlertDialog()
    public func showSingleAlert(title: String, message: String, viewController: UIViewController, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in completion()
        }
        alert.addAction(ok)
        //TODO: parent → present
        viewController.present(alert, animated: true, completion: nil)
    }
    
    public func showSingleSheet(title: String, message: String, viewController: UIViewController, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in completion()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .default, handler: {
            //ボタンが押された時の処理
            (action: UIAlertAction) -> Void in
            print("キャンセル")
        })
        alert.addAction(ok)
        alert.addAction(cancelAction)
        //TODO: parent → present
        viewController.present(alert, animated: true, completion: nil)
    }
    
    public func showSaveWithTextAlert(vc: UIViewController, completion: @escaping( _ text: String)->Void){
        let avc = UIAlertController(title: "Save", message: "put a name to the video",preferredStyle: .alert)
        avc.addTextField()
        avc.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let text = avc.textFields?.first?.text{
                completion(text)
            }
        }))
        vc.present(avc, animated: true, completion: nil)
    }
    public func showDoubleAlert(title: String,message: String,viewController: UIViewController,firstCompletion: @escaping() -> Void, secondCompletion: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let replay = UIAlertAction(title: "動画再生", style: .default) {(action) in firstCompletion()}
        let delet = UIAlertAction(title: "削除", style: .destructive, handler: {(action: UIAlertAction) -> Void in
            print("destructive")
        })
        alert.addAction(replay)
        alert.addAction(delet)
    }
}
