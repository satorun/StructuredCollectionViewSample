//
//  Item.swift
//  StructuredCollectionViewSample
//
//

import UIKit

/// アイテムを表す構造体
struct Item: Hashable {
    /// アイテムの一意識別子
    let id: UUID
    
    /// アイテムのタイトル
    let title: String
    
    /// アイテムの表示色
    let color: UIColor
    
    /// 初期化
    /// - Parameters:
    ///   - title: アイテムのタイトル
    ///   - color: アイテムの表示色
    init(title: String, color: UIColor) {
        self.id = UUID()
        self.title = title
        self.color = color
    }
    
    // MARK: - Hashable実装
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable実装
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
} 
