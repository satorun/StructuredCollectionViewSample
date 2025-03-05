//
//  Banner.swift
//  StructuredCollectionViewSample
//
//

import UIKit

/// コレクションビューに表示するバナーを表す構造体
struct Banner: Hashable {
    /// バナーの一意識別子
    let id: UUID
    
    /// バナーのタイトル
    let title: String
    
    /// バナーの表示画像名
    let imageName: String
    
    /// バナーの背景色
    let backgroundColor: UIColor
    
    /// 初期化
    /// - Parameters:
    ///   - title: バナーのタイトル
    ///   - imageName: 画像の名前
    ///   - backgroundColor: 背景色
    init(title: String, imageName: String, backgroundColor: UIColor) {
        self.id = UUID()
        self.title = title
        self.imageName = imageName
        self.backgroundColor = backgroundColor
    }
    
    // MARK: - Hashable実装
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable実装
    static func == (lhs: Banner, rhs: Banner) -> Bool {
        return lhs.id == rhs.id
    }
} 
