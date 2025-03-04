//
//  CollectionViewLayoutFactory.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import UIKit

/// コレクションビューのレイアウトを生成するファクトリークラス
class CollectionViewLayoutFactory {
    
    /// 多階層カテゴリ表示用のCompositionalLayoutを作成する
    /// - Parameter sectionTypes: 各セクションのタイプ情報を含む配列
    /// - Returns: 設定済みのUICollectionViewLayout
    static func createCompositionalLayout(sectionTypes: [SectionType]) -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            // セクションのインデックスに基づいてレイアウトを選択
            guard sectionIndex < sectionTypes.count else {
                return Self.createCategorySection() // デフォルトレイアウト
            }
            
            // セクションタイプに基づいてレイアウトを選択
            let sectionType = sectionTypes[sectionIndex]
            switch sectionType {
            case .banner:
                return Self.createBannerSection()
            case .recommendations:
                return Self.createRecommendedItemsSection()
            case .category:
                return Self.createCategorySection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    /// バナーセクションのレイアウトを作成（水平スクロールカルーセル）
    /// - Returns: NSCollectionLayoutSection
    static func createBannerSection() -> NSCollectionLayoutSection {
        // バナーアイテムのレイアウト
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        // バナーグループのレイアウト（フルスクリーン幅の85%）
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.85),
            heightDimension: .absolute(180)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        // バナーセクション定義（水平スクロール）
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 12, bottom: 16, trailing: 12)
        
        // ヘッダー定義
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    /// おすすめアイテムセクションのレイアウトを作成（ページングスタイル - カテゴリセクションに合わせたスタイル）
    /// - Returns: NSCollectionLayoutSection
    static func createRecommendedItemsSection() -> NSCollectionLayoutSection {
        // アイテムのレイアウト（カテゴリセクションと同じサイズに）
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),  // グループ内で50%幅（2つで1グループ）
            heightDimension: .fractionalHeight(1.0) // グループの高さに合わせる
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        // 2アイテムを1グループとして扱う
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),  // 画面幅の90%（カテゴリセクションに近い幅）
            heightDimension: .absolute(100)         // カテゴリセクションと同じ高さ
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2  // 1グループに2アイテム
        )
        
        // おすすめセクション定義
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging  // 左端から始まるページング
        section.interGroupSpacing = 0  // グループ間の間隔
        
        // セクション余白設定（左端の余白を減らす）
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8)
        
        // ヘッダー定義
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    /// カテゴリセクションのレイアウトを作成
    /// - Returns: NSCollectionLayoutSection
    static func createCategorySection() -> NSCollectionLayoutSection {
        // 2つの異なるアイテム種類を持つセクションを作成
        
        // サブカテゴリのアイテムレイアウト（幅いっぱい）
        let subCategoryItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
        )
        subCategoryItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8)
        
        // サブカテゴリのグループ
        let subCategoryGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            ),
            subitems: [subCategoryItem]
        )
        
        // アイテムのレイアウト（2つのアイテムを横に並べる）
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        // アイテムのグループ（2つ横並び）
        let itemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let itemGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemGroupSize,
            subitem: item,
            count: 2
        )
        
        // セクション定義（サブカテゴリの後にアイテムグループを表示）
        let section = NSCollectionLayoutSection(group: itemGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        // セクションヘッダー追加
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    /// グリッドスタイルのセクションレイアウトを作成
    /// - Returns: NSCollectionLayoutSection
    static func createGridSection() -> NSCollectionLayoutSection {
        // アイテムサイズ定義
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        // グループサイズ定義
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // セクション定義
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        // セクションヘッダー追加
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    /// リストスタイルのセクションレイアウトを作成
    /// - Returns: NSCollectionLayoutSection
    static func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    /// 水平スクロールスタイルのセクションレイアウトを作成
    /// - Returns: NSCollectionLayoutSection
    static func createHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6),
                                              heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
} 