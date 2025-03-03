//
//  ViewController.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // データソースを管理するオブジェクト
    private var collectionViewDataSource: CollectionViewDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // コレクションビューのレイアウト設定
        collectionView.collectionViewLayout = CollectionViewLayoutFactory.createCompositionalLayout()
        
        // データソースの設定
        collectionViewDataSource = CollectionViewDataSource(collectionView: collectionView)
        
        // 初期データをロード
        collectionViewDataSource.applyInitialSnapshots()
    }
}

