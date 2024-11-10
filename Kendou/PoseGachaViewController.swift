//
//  PoseGachaViewController.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/11/10.
//

import UIKit
import SwiftUI

class PoseGachaViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var autoScrollTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
    }
    private func configureCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        //レイアウト調整
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 500)
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }
}
extension PoseGachaViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GachaCell", for: indexPath)
        cell.contentConfiguration = UIHostingConfiguration(content: {
            PoseListCell()
        })
        return cell
    }
}
