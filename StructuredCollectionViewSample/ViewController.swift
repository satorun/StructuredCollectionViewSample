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
        
        setupCollectionView()
        setupNavigationBar()
    }
    
    // コレクションビューの設定
    private func setupCollectionView() {
        // コレクションビューのレイアウト設定
        collectionView.collectionViewLayout = CollectionViewLayoutFactory.createCompositionalLayout()
        
        // データソースの設定
        collectionViewDataSource = CollectionViewDataSource(collectionView: collectionView)
        
        // 初期データをロード
        collectionViewDataSource.applyInitialSnapshots()
    }
    
    // ナビゲーションバーの設定
    private func setupNavigationBar() {
        title = "カテゴリ表示サンプル"
        
        // リロードボタンを追加
        let reloadButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(reloadData)
        )
        navigationItem.rightBarButtonItem = reloadButton
    }
    
    // データをリロードするアクション
    @objc private func reloadData() {
        // 食べ物カテゴリのアイテムを更新
        let newFoodItems = [
            Item(title: "いちご", color: .systemRed),
            Item(title: "メロン", color: .systemGreen),
            Item(title: "パイナップル", color: .systemYellow),
            Item(title: "すいか", color: .systemGreen),
            Item(title: "キウイ", color: .systemGreen)
        ]
        
        let foodCategory = Category(name: "果物", items: newFoodItems)
        let hobbiesItems = [
            Item(title: "読書", color: .systemBrown),
            Item(title: "ゲーム", color: .systemBlue),
            Item(title: "映画鑑賞", color: .systemRed),
            Item(title: "料理", color: .systemOrange)
        ]
        
        let hobbiesCategory = Category(name: "趣味", items: hobbiesItems)
        
        // 新しいカテゴリを設定してリロード
        collectionViewDataSource.reloadCategories([foodCategory, hobbiesCategory])
    }
}

