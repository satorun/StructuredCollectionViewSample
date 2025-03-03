//
//  Item.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import UIKit

// アイテムモデル
struct Category: Hashable {
    var id: UUID
    var name: String
    var subCategories: [SubCategory]

    init(name: String, subCategories: [SubCategory]) {
        self.id = UUID()
        self.name = name
        self.subCategories = subCategories
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

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