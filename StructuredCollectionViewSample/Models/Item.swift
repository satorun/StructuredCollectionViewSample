//
//  Item.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import UIKit

// アイテムモデル
struct Item: Hashable {
    let id: UUID
    let title: String
    let color: UIColor
    
    init(title: String, color: UIColor) {
        self.id = UUID()
        self.title = title
        self.color = color
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
} 