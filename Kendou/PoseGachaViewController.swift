//
//  PoseGachaViewController.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/11/10.
//

import UIKit
import SwiftUI

struct PoseModel {
    let name: PosePattern
    let description: String
    let imageRSC: String
    
    init(name: PosePattern, description: String, imageRSC: String) {
        self.name = name
        self.description = description
        self.imageRSC = imageRSC
    }
}

enum PosePattern: String {
    case TreePose = "TreePose"
    case TrianglePose = "TrianglePose"
    case WarriorPose = "WarriorPose"
    case WarriorPose2 = "WarriorPose2"
    case none = "none"
}

class PoseGachaViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var autoScrollTimer = Timer()
    var posePattern: PosePattern = .none
    var poseArray: [PoseModel] = []
    var percentage: Double = 0
    
    let isInfinity = true
    var cellItemsWidth: CGFloat = 0.0
    var status = "left"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCollectionView()
        self.composePoseArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showPercentage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetect" {
            let vc = segue.destination as! PoseDetectionViewController
            vc.posePattern = self.posePattern
        }
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        //レイアウトを調整
        let layout = FlowLayout()
        layout.itemSize = CGSize(width: 300, height: 500)
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = collectionView.bounds.height
        layout.minimumLineSpacing = 20
        collectionView.collectionViewLayout = layout
    }
    
    // 自動スクロールを開始する
    private func startAutoScroll(duration: TimeInterval, direction: ScrollDirectionType) {
        let randomInt: Int = Int.random(in: 1...10)
        // 表示中のIndexPathを取得
        var indexPath = collectionView.indexPathsForVisibleItems.sorted { $0.item < $1.item }.first ?? IndexPath(item: 0, section: 0)
        // 最初のItem
        let firstItem = IndexPath(item: 0, section: 0)
        // 最後のItem
        let lastItem = IndexPath(item: collectionView.numberOfItems(inSection: 0) - 1, section: 0)
        // 自動スクロールを終了させるかどうか
        var shouldFinish = false
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            // item2つ分ずつスクロールさせる
            switch direction {
            case .left:
                indexPath = (indexPath.item + randomInt >= self.collectionView.numberOfItems(inSection: 0)) ? lastItem : IndexPath(item: indexPath.item + randomInt, section: 0)
                shouldFinish = indexPath.item == lastItem.item
            case .right:
                indexPath = (indexPath.item - randomInt <= 0) ? firstItem : IndexPath(item: indexPath.item - randomInt, section: 0)
                shouldFinish = indexPath.item == firstItem.item
            default: break
            }
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.posePattern = self.poseArray[indexPath.row % self.poseArray.count].name
                print(self.posePattern.rawValue)
                if shouldFinish { self.stopAutoScrollIfNeeded() }
            }
        })
    }
    
    // 自動スクロールを停止する
    private func stopAutoScrollIfNeeded() {
        if autoScrollTimer.isValid {
            view.layer.removeAllAnimations()
            autoScrollTimer.invalidate()
            AlertDialog.shared.showSingleSheet(title: "カードに表示されたポーズを取ってください", message: "OKを押したらカメラを起動します", viewController: self) {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.performSegue(withIdentifier: "toDetect", sender: nil)
                }
            }
        }
    }
    
    private func composePoseArray() {
        let tree = PoseModel(name: .TreePose, description: "ツリーポーズです。手を上部で重ね合わせ、片足で立ちます。", imageRSC: "tree")
        let warrior = PoseModel(name: .WarriorPose, description: "戦士のポーズです。片足を後ろに引き、腰を真下におろして安定した下半身を作ります。", imageRSC: "warrior")
        let warrior2 = PoseModel(name: .WarriorPose2, description: "戦士のポーズ2です。片足を後ろに引き、腰を真下におろして安定した下半身を作ります。両手を肩の高さに上げて視線は手の先に向けます。", imageRSC: "warrior2")
        let triangle = PoseModel(name: .TrianglePose, description: "三角のポーズです。両脚でしっかりと床を踏み、カラダ全体で大きく三角をつくり、体幹を使ってカラダをしっかり引き上げます。", imageRSC: "triangle")
        
        poseArray.append(contentsOf: [tree, warrior, warrior2, triangle])
    }
    
    enum ScrollDirectionType {
        case upper, under, left, right
    }
    
    @IBAction func tappedGachaButton(_ sender: Any) {
        if self.status == "left" {
            self.startAutoScroll(duration: 1, direction: .left)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.stopAutoScrollIfNeeded()
                self.status = "right"
            }
        } else if self.status == "right"{
            self.startAutoScroll(duration: 1, direction: .right)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.stopAutoScrollIfNeeded()
                self.status = "left"
            }
        }
    }
    
    func showPercentage() {
        if percentage > 0 {
            AlertDialog.shared.showSingleAlert(title: "動画をカメラロールに保存しました", message: "\(posePattern.rawValue): \(percentage)%でした", viewController: self) {
                self.percentage = 0
            }
        }
    }
}

extension PoseGachaViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return poseArray.count * 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GachaCell", for: indexPath)
        let poseContent = poseArray[indexPath.row % self.poseArray.count]
        cell.contentConfiguration = UIHostingConfiguration(content: {
            PoseListCell(title: poseContent.name.rawValue, description: poseContent.description, imageRsc: poseContent.imageRSC)
        })
        return cell
    }
}

extension PoseGachaViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isInfinity {
            if cellItemsWidth == 0.0 {
                cellItemsWidth = floor(scrollView.contentSize.width / 3.0) // 表示したい要素群のwidthを計算
            }
            
            if (scrollView.contentOffset.x <= 0.0) || (scrollView.contentOffset.x > cellItemsWidth * 2.0) { // スクロールした位置がしきい値を超えたら中央に戻す
                scrollView.contentOffset.x = cellItemsWidth
            }
        }
    }
}

extension PoseGachaViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let collectionView = scrollView as! UICollectionView
        (collectionView.collectionViewLayout as! FlowLayout).prepareForPaging()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) }
        let screenSizeWidth = window.screen.bounds.width
        let inset = (screenSizeWidth - 300)/2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}
