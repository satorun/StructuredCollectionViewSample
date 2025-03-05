//
//  Section.swift
//  StructuredCollectionViewSample
//
//

import Foundation

/// セクションの種類を表す列挙型
enum SectionType {
    /// カテゴリセクション
    case category(Category)
    
    /// バナーセクション
    case banner
    
    /// おすすめアイテムセクション
    case recommendations
}

/// コレクションビューのセクションを表すモデル
/// UICollectionViewDiffableDataSourceのセクション識別に使用
struct Section: Hashable {
    /// セクションの一意識別子
    let id = UUID()
    
    /// セクションの種類
    let type: SectionType
    
    /// セクションのタイトル
    var title: String {
        switch type {
        case .category(let category):
            return category.name
        case .banner:
            return "特集バナー"
        case .recommendations:
            return "おすすめアイテム"
        }
    }
    
    /// カテゴリセクションの初期化
    /// - Parameter category: セクションに関連付けるカテゴリ
    init(category: Category) {
        self.type = .category(category)
    }
    
    /// バナーセクションの初期化
    init(banner: Void) {
        self.type = .banner
    }
    
    /// おすすめセクションの初期化
    init(recommendations: Void) {
        self.type = .recommendations
    }
    
    // MARK: - Equatableの実装
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashableの実装
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 
