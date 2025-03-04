//
//  Category.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import Foundation

/// カテゴリを表す構造体
struct Category: Hashable {
    /// カテゴリの一意識別子
    let id: UUID
    
    /// カテゴリの名前
    let name: String
    
    /// カテゴリに含まれるサブカテゴリ
    var subCategories: [SubCategory]

    /// 初期化
    /// - Parameters:
    ///   - name: カテゴリ名
    ///   - subCategories: サブカテゴリの配列
    init(name: String, subCategories: [SubCategory]) {
        self.id = UUID()
        self.name = name
        self.subCategories = subCategories
    }

    // MARK: - Hashable実装
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable実装
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
} 