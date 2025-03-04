//
//  Section.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import Foundation

/// コレクションビューのセクションを表すモデル
/// UICollectionViewDiffableDataSourceのセクション識別に使用
struct Section: Hashable {
    /// セクションの一意識別子
    let id = UUID()
    
    /// セクションに関連付けられたカテゴリ
    let category: Category
    
    /// セクションのタイトル（カテゴリ名）
    var title: String {
        return category.name
    }
    
    /// 初期化
    /// - Parameter category: セクションに関連付けるカテゴリ
    init(category: Category) {
        self.category = category
    }
    
    // MARK: - Equatableの実装
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashableの実装
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 