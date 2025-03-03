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
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
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
            label.text = Section(rawValue: indexPath.section)?.title
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
        // 各セクションのデータを作成
        let gridItems = (0..<10).map { Item(title: "グリッド \($0)", color: .systemBlue) }
        let listItems = (0..<10).map { Item(title: "リスト \($0)", color: .systemGreen) }
        let horizontalItems = (0..<10).map { Item(title: "水平 \($0)", color: .systemOrange) }
        
        // スナップショットを作成
        var snapshot: NSDiffableDataSourceSnapshot<Section, Item> = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.grid, .list, .horizontal])
        snapshot.appendItems(gridItems, toSection: .grid)
        snapshot.appendItems(listItems, toSection: .list)
        snapshot.appendItems(horizontalItems, toSection: .horizontal)
        
        // スナップショットを適用
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    /// 指定されたセクションのアイテムを効率的に更新する（セクション順序を維持）
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
} 