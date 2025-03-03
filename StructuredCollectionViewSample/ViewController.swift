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
        title = "多階層カテゴリサンプル"
        
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
        // 新しいカテゴリとサブカテゴリ、アイテムを作成
        
        // 家電カテゴリ
        let kitchenItems = [
            Item(title: "冷蔵庫", color: .systemBlue),
            Item(title: "電子レンジ", color: .systemGray),
            Item(title: "トースター", color: .systemOrange)
        ]
        
        let avItems = [
            Item(title: "テレビ", color: .systemPurple),
            Item(title: "ゲーム機", color: .systemGreen),
            Item(title: "スピーカー", color: .systemRed)
        ]
        
        let applianceSubs = [
            SubCategory(name: "キッチン家電", items: kitchenItems),
            SubCategory(name: "AV機器", items: avItems)
        ]
        
        // 季節カテゴリ
        let springItems = [
            Item(title: "桜", color: .systemPink),
            Item(title: "チューリップ", color: .systemRed)
        ]
        
        let summerItems = [
            Item(title: "ひまわり", color: .systemYellow),
            Item(title: "海", color: .systemBlue)
        ]
        
        let fallItems = [
            Item(title: "紅葉", color: .systemOrange),
            Item(title: "きのこ", color: .systemBrown)
        ]
        
        let seasonSubs = [
            SubCategory(name: "春", items: springItems),
            SubCategory(name: "夏", items: summerItems),
            SubCategory(name: "秋", items: fallItems)
        ]
        
        // 新しいカテゴリを作成してリロード
        let categories = [
            Category(name: "家電製品", subCategories: applianceSubs),
            Category(name: "季節", subCategories: seasonSubs)
        ]
        
        collectionViewDataSource.reloadCategories(categories)
    }
}

