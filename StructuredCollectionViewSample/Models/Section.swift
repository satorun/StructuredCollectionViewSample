//
//  Section.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import Foundation

// セクションを表すモデル
struct Section: Hashable {
    // セクションのカテゴリ
    let category: Category
    
    // セクションのタイトル（カテゴリ名）
    var title: String {
        return category.name
    }
    
    // Equatableの実装
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.category.id == rhs.category.id
    }
    
    // Hashableの実装
    func hash(into hasher: inout Hasher) {
        hasher.combine(category.id)
    }
} 