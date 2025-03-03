//
//  Section.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import Foundation

// セクションの種類を定義するenum
enum Section: Int, CaseIterable {
    case grid
    case list
    case horizontal
    
    var title: String {
        switch self {
        case .grid:
            return "グリッド"
        case .list:
            return "リスト"
        case .horizontal:
            return "水平スクロール"
        }
    }
} 