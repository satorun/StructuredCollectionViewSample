//
//  Section.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import Foundation

/// セクションを表すモデル
struct Section: Hashable {
    /// セクションのID（一意な識別子）
    let id = UUID()
    
    /// セクションのカテゴリ
    let category: Category
    
    /// セクションのタイトル（カテゴリ名）
    var title: String {
        return category.name
    }
    
    /// 初期化
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