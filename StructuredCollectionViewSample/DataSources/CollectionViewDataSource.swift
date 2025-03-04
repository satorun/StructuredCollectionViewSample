//
//  CollectionViewDataSource.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import UIKit

/// UICollectionViewDiffableDataSourceの設定と管理を担当するクラス
class CollectionViewDataSource {
    
    /// データソースの識別子
    enum CellReuseID: String {
        /// サブカテゴリセル
        case subCategory = "SubCategoryCell"
        /// アイテムセル
        case item = "ItemCell"
    }
    
    /// DiffableDataSource
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, CellItem>!
    
    /// カテゴリのリスト
    private var categories: [Category] = []
    
    /// 指定されたコレクションビューに対してデータソースを設定
    /// - Parameter collectionView: 設定対象のコレクションビュー
    init(collectionView: UICollectionView) {
        configureDataSource(collectionView: collectionView)
    }
    
    /// データソースを設定
    /// - Parameter collectionView: 設定対象のコレクションビュー
    private func configureDataSource(collectionView: UICollectionView) {
        registerCells(collectionView: collectionView)
        configureCellProvider(collectionView: collectionView)
        configureHeaderProvider()
    }
    
    /// セルとヘッダーを登録
    /// - Parameter collectionView: 設定対象のコレクションビュー
    private func registerCells(collectionView: UICollectionView) {
        // セルの登録
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseID.subCategory.rawValue)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseID.item.rawValue)
        
        // ヘッダーの登録
        collectionView.register(UICollectionReusableView.self,
                               forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                               withReuseIdentifier: "HeaderView")
    }
    
    /// セルプロバイダーの設定
    /// - Parameter collectionView: 設定対象のコレクションビュー
    private func configureCellProvider(collectionView: UICollectionView) {
        dataSource = UICollectionViewDiffableDataSource<Section, CellItem>(collectionView: collectionView) { 
            [weak self] (collectionView: UICollectionView, indexPath: IndexPath, cellItem: CellItem) -> UICollectionViewCell? in
            
            switch cellItem {
            case .subCategory(let subCategory):
                return self?.configureSubCategoryCell(collectionView: collectionView, indexPath: indexPath, subCategory: subCategory)
                
            case .item(let item, _):
                return self?.configureItemCell(collectionView: collectionView, indexPath: indexPath, item: item)
            }
        }
    }
    
    /// サブカテゴリセルの構成
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    ///   - subCategory: 表示するサブカテゴリ
    /// - Returns: 設定されたセル
    private func configureSubCategoryCell(collectionView: UICollectionView, indexPath: IndexPath, subCategory: SubCategory) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellReuseID.subCategory.rawValue,
            for: indexPath) as? UICollectionViewCell else {
                return nil
        }
        
        // サブカテゴリセルの内容を設定
        var config = UIListContentConfiguration.subtitleCell()
        config.text = subCategory.name
        config.secondaryText = "\(subCategory.items.count)個のアイテム"
        config.textProperties.font = UIFont.boldSystemFont(ofSize: 16)
        cell.contentConfiguration = config
        cell.backgroundColor = UIColor.systemGray6
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }
    
    /// アイテムセルの構成
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    ///   - item: 表示するアイテム
    /// - Returns: 設定されたセル
    private func configureItemCell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellReuseID.item.rawValue,
            for: indexPath) as? UICollectionViewCell else {
                return nil
        }
        
        // アイテムセルの内容を設定
        var config = UIListContentConfiguration.cell()
        config.text = item.title
        cell.contentConfiguration = config
        cell.backgroundColor = item.color
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }
    
    /// ヘッダープロバイダーの設定
    private func configureHeaderProvider() {
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HeaderView",
                for: indexPath)
            
            // 既存のサブビューをクリア
            headerView.subviews.forEach { $0.removeFromSuperview() }
            
            // ヘッダーにラベルを追加
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.boldSystemFont(ofSize: 18)
            
            // 現在のスナップショットからセクションを取得
            guard let sections = self?.dataSource.snapshot().sectionIdentifiers,
                  indexPath.section < sections.count else {
                label.text = "不明なセクション"
                return headerView
            }
            
            label.text = sections[indexPath.section].title
            headerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            
            return headerView
        }
    }
    
    /// 初期データをロード
    func applyInitialSnapshots() {
        // フルーツカテゴリ
        let fruitItems1 = [
            Item(title: "りんご", color: .systemRed),
            Item(title: "バナナ", color: .systemYellow)
        ]
        
        let fruitItems2 = [
            Item(title: "オレンジ", color: .systemOrange),
            Item(title: "ぶどう", color: .purple)
        ]
        
        let fruitSubs = [
            SubCategory(name: "国産フルーツ", items: fruitItems1),
            SubCategory(name: "輸入フルーツ", items: fruitItems2)
        ]
        
        // スポーツカテゴリ
        let ballSportsItems = [
            Item(title: "サッカー", color: .systemGreen),
            Item(title: "野球", color: .systemBlue),
            Item(title: "バスケットボール", color: .systemOrange)
        ]
        
        let racketSportsItems = [
            Item(title: "テニス", color: .systemYellow),
            Item(title: "バドミントン", color: .systemCyan)
        ]
        
        let sportsSubs = [
            SubCategory(name: "ボールスポーツ", items: ballSportsItems),
            SubCategory(name: "ラケットスポーツ", items: racketSportsItems)
        ]
        
        // 旅行カテゴリ
        let domesticPlaces = [
            Item(title: "京都", color: .systemRed),
            Item(title: "北海道", color: .systemCyan),
            Item(title: "沖縄", color: .systemBlue)
        ]
        
        let overseasPlaces = [
            Item(title: "ハワイ", color: .systemGreen),
            Item(title: "パリ", color: .systemPink),
            Item(title: "ニューヨーク", color: .systemGray)
        ]
        
        let travelSubs = [
            SubCategory(name: "国内", items: domesticPlaces),
            SubCategory(name: "海外", items: overseasPlaces)
        ]
        
        // カテゴリを作成
        categories = [
            Category(name: "フルーツ", subCategories: fruitSubs),
            Category(name: "スポーツ", subCategories: sportsSubs),
            Category(name: "旅行先", subCategories: travelSubs)
        ]
        
        // セクションを更新
        updateSections()
    }
    
    /// カテゴリをリロードする
    /// - Parameters:
    ///   - categories: 新しいカテゴリ配列
    ///   - animate: アニメーションの有無
    func reloadCategories(_ categories: [Category], animate: Bool = true) {
        self.categories = categories
        updateSections(animate: animate)
    }
    
    /// セクションとアイテムを更新する
    /// - Parameter animate: アニメーションの有無
    private func updateSections(animate: Bool = false) {
        // 新しいスナップショットを作成
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellItem>()
        
        // カテゴリごとにセクションとセルアイテムを作成
        for category in categories {
            // セクションを作成
            let section = Section(category: category)
            snapshot.appendSections([section])
            
            // サブカテゴリとアイテムをセルアイテムとして追加
            for subCategory in category.subCategories {
                // まずサブカテゴリのセルを追加
                let subCategoryCell = CellItem.subCategory(subCategory)
                snapshot.appendItems([subCategoryCell], toSection: section)
                
                // 続いて、そのサブカテゴリに含まれるアイテムを追加
                let itemCells = subCategory.items.map { CellItem.item($0, subCategory) }
                snapshot.appendItems(itemCells, toSection: section)
            }
        }
        
        // スナップショットを適用
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
} 