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
        case basic = "BasicCell"
    }
    
    /// DiffableDataSource
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
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
        // セルの登録
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseID.basic.rawValue)
        
        // ヘッダーの登録
        collectionView.register(UICollectionReusableView.self,
                               forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                               withReuseIdentifier: "HeaderView")
        
        // セルプロバイダーの設定
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellReuseID.basic.rawValue,
                for: indexPath) as? UICollectionViewCell else {
                    return nil
            }
            
            // セルの内容を設定
            var config = UIListContentConfiguration.cell()
            config.text = item.title
            cell.contentConfiguration = config
            cell.backgroundColor = item.color
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true
            
            return cell
        }
        
        // ヘッダービュープロバイダーの設定
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
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
        // カテゴリとアイテムを作成
        let foodItems = [
            Item(title: "りんご", color: .systemRed),
            Item(title: "バナナ", color: .systemYellow),
            Item(title: "オレンジ", color: .systemOrange),
            Item(title: "ぶどう", color: .purple)
        ]
        
        let sportsItems = [
            Item(title: "サッカー", color: .systemGreen),
            Item(title: "野球", color: .systemBlue),
            Item(title: "バスケットボール", color: .systemOrange),
            Item(title: "テニス", color: .systemYellow)
        ]
        
        let travelItems = [
            Item(title: "京都", color: .systemRed),
            Item(title: "沖縄", color: .systemBlue),
            Item(title: "北海道", color: .systemCyan),
            Item(title: "東京", color: .systemGray)
        ]
        
        // カテゴリを作成
        categories = [
            Category(name: "食べ物", items: foodItems),
            Category(name: "スポーツ", items: sportsItems),
            Category(name: "旅行先", items: travelItems)
        ]
        
        // セクションを作成
        let sections: [Section] = categories.map { Section(category: $0) }
        
        // スナップショットを作成
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        // セクションとアイテムを追加
        for (index, section) in sections.enumerated() {
            snapshot.appendSections([section])
            snapshot.appendItems(categories[index].items, toSection: section)
        }
        
        // スナップショットを適用
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    /// 指定されたセクションのアイテムを効率的に更新する
    /// - Parameters:
    ///   - section: 更新対象のセクション
    ///   - items: 新しいアイテム配列
    ///   - animate: アニメーションの有無
    func updateSection(_ section: Section, with items: [Item], animate: Bool = true) {
        // 現在のスナップショットを複製（値型なのでこれだけで複製される）
        var newSnapshot = dataSource.snapshot()
        
        // 指定されたセクションのアイテムだけを削除
        let currentItems = newSnapshot.itemIdentifiers(inSection: section)
        newSnapshot.deleteItems(currentItems)
        
        // 新しいアイテムを追加
        newSnapshot.appendItems(items, toSection: section)
        
        // スナップショットを適用（DiffableDataSourceが自動的に差分を計算）
        dataSource.apply(newSnapshot, animatingDifferences: animate)
    }
    
    /// カテゴリをリロードする
    /// - Parameters:
    ///   - categories: 新しいカテゴリ配列
    ///   - animate: アニメーションの有無
    func reloadCategories(_ categories: [Category], animate: Bool = true) {
        self.categories = categories
        
        // セクションを作成
        let sections: [Section] = categories.map { Section(category: $0) }
        
        // 新しいスナップショットを作成
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        // セクションとアイテムを追加
        for (index, section) in sections.enumerated() {
            snapshot.appendSections([section])
            snapshot.appendItems(categories[index].items, toSection: section)
        }
        
        // スナップショットを適用
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
} 