//
//  SubCategory.swift
//  StructuredCollectionViewSample
//
//

import Foundation

/// サブカテゴリを表す構造体
struct SubCategory: Hashable {
    /// サブカテゴリの一意識別子
    let id: UUID
    
    /// サブカテゴリの名前
    let name: String
    
    /// サブカテゴリに含まれるアイテム
    var items: [Item]
    
    /// 初期化
    /// - Parameters:
    ///   - name: サブカテゴリ名
    ///   - items: アイテムの配列
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
