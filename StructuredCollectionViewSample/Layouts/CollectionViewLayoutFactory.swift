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
            case .category(let category):
                // 動的なカテゴリレイアウトを使用
                return Self.createNestedCategoryLayout(with: sectionType)
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
            heightDimension: .estimated(180)
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
            heightDimension: .estimated(100)         // カテゴリセクションと同じ高さ
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
        // アイテムのレイアウト（2カラム）
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        // 2カラムのアイテムグループ
        let itemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let itemGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemGroupSize,
            subitem: item,
            count: 2
        )
        
        // セクション定義
        let section = NSCollectionLayoutSection(group: itemGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 24, trailing: 12)
        
        // セクションヘッダー
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
    
    /// カテゴリセクション用のネストされたレイアウトを作成（サブカテゴリとアイテム）
    /// - Parameter sectionType: セクションタイプ
    /// - Returns: NSCollectionLayoutSection
    static func createNestedCategoryLayout(with sectionType: SectionType) -> NSCollectionLayoutSection {
        // sectionTypeからカテゴリ情報を取得
        guard case .category(let category) = sectionType else {
            // 通常のカテゴリセクションを返す（フォールバック）
            return createCategorySection()
        }
        
        // アイテムセル用レイアウト（2カラム）
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        // 2カラムアイテムグループ
        let itemGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let itemGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemGroupSize,
            subitem: item,
            count: 2  // 常に2カラム
        )
        
        // 奇数アイテム用の1アイテムグループ（1つのみ表示）
        let singleItemGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemGroupSize,
            subitem: item,
            count: 1  // 1アイテムのみ
        )
        
        // サブカテゴリをタイトル行として表示するためのレイアウト
        let titleHeight: CGFloat = 44
        let titleSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(titleHeight)
        )
        let titleItem = NSCollectionLayoutItem(layoutSize: titleSize)
        
        // タイトル用の余白調整（シンプルでタイトルらしい見た目に）
        titleItem.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 8,
            bottom: 8,
            trailing: 8
        )
        
        // サブカテゴリごとにグループを作成（タイトル + アイテム）
        var categoryGroups: [NSCollectionLayoutGroup] = []
        
        for subCategory in category.subCategories {
            // サブカテゴリタイトル用のグループ
            let titleGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: titleSize,
                subitems: [titleItem]
            )
            
            // アイテム数に基づいて必要な行数を計算
            let itemCount = subCategory.items.count
            let fullRows = itemCount / 2      // 完全な行数（2アイテムずつ）
            let hasPartialRow = itemCount % 2 != 0 // 奇数アイテムの場合
            
            // アイテム行を格納する配列
            var itemRows: [NSCollectionLayoutGroup] = []
            
            // 完全な行（2アイテム）を追加
            for _ in 0..<fullRows {
                itemRows.append(itemGroup)
            }
            
            // 奇数アイテムがある場合、単一アイテムグループを追加
            if hasPartialRow {
                itemRows.append(singleItemGroup)
            }
            
            // このサブカテゴリの推定高さを計算
            let estimatedHeight = titleHeight + CGFloat(itemRows.count) * 100
            
            // タイトルとアイテム行を組み合わせた垂直グループを作成
            var allItems = [titleGroup]
            allItems.append(contentsOf: itemRows)
            
            let subCategoryGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(estimatedHeight)
                ),
                subitems: allItems
            )
            
            categoryGroups.append(subCategoryGroup)
        }
        
        // すべてのサブカテゴリグループを垂直に並べる
        let mainGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(CGFloat(categoryGroups.count) * 200) // 十分な高さを確保
            ),
            subitems: categoryGroups
        )
        
        // セクション定義
        let section = NSCollectionLayoutSection(group: mainGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 24, trailing: 12)
        
        // カテゴリのメインヘッダー
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
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        // グループサイズ定義
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // セクション定義
        let section = NSCollectionLayoutSection(group: group)
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
    
    /// リストスタイルのセクションレイアウトを作成
    /// - Returns: NSCollectionLayoutSection
    static func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
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
    
    /// 水平スクロールスタイルのセクションレイアウトを作成
    /// - Returns: NSCollectionLayoutSection
    static func createHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.6),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
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
} 