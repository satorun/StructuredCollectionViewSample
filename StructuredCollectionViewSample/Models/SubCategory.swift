//
//  SubCategory.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import Foundation

/// サブカテゴリを表す構造体
struct SubCategory: Hashable {
    /// サブカテゴリのID
    let id: UUID
    
    /// サブカテゴリの名前
    let name: String
    
    /// サブカテゴリに含まれるアイテム
    var items: [Item]
    
    /// 初期化
    init(name: String, items: [Item]) {
        self.id = UUID()
        self.name = name
        self.items = items
    }
    
    // MARK: - Hashable実装
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable実装
    static func == (lhs: SubCategory, rhs: SubCategory) -> Bool {
        return lhs.id == rhs.id
    }
} 