//
//  CellItem.swift
//  StructuredCollectionViewSample
//
//

import Foundation

/// コレクションビューに表示するセルアイテムの種類を表す列挙型
/// DiffableDataSourceのアイテム識別に使用
enum CellItem: Hashable {
    /// サブカテゴリのセル
    case subCategory(SubCategory)
    
    /// アイテムのセル（SubCategoryの参照を保持）
    case item(Item, SubCategory?)
    
    /// バナーのセル
    case banner(Banner)
    
    /// セルアイテムのID（Hashable実装のため）
    var id: String {
        switch self {
        case .subCategory(let subCategory):
            return "sub_\(subCategory.id)"
        case .item(let item, let subCategory):
            if let subCategory = subCategory {
                return "item_\(item.id)_\(subCategory.id)"
            } else {
                return "item_\(item.id)_recommended"
            }
        case .banner(let banner):
            return "banner_\(banner.id)"
        }
    }
    
    // MARK: - Hashable実装
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable実装
    static func == (lhs: CellItem, rhs: CellItem) -> Bool {
        return lhs.id == rhs.id
    }
} 
