//
//  DataProvider.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/04.
//

import UIKit

/// 実際のサーバー通信を行うデータプロバイダー
/// 本番環境で使用する実装
class DataProvider {
    
    /// 共有インスタンス
    static let shared = DataProvider()
    
    /// プライベートコンストラクタ（シングルトンパターン）
    private init() {}
    
    /// すべてのデータを一度に取得する
    /// - Returns: バナー、カテゴリ、おすすめアイテムのタプル
    func fetchAllData() async throws -> (banners: [Banner], categories: [Category], recommendedItems: [Item]) {
        // 非同期処理をシミュレート（実際のアプリではAPIリクエスト）
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒の遅延
        
        // バナーデータの生成
        let banners = createInitialBanners()
        
        // カテゴリデータの生成
        let categories = createInitialCategories()
        
        // おすすめアイテムの生成
        let recommendedItems = createInitialRecommendedItems()
        
        // 成功時はデータを直接返す
        return (banners: banners, categories: categories, recommendedItems: recommendedItems)
    }
    
    /// データ更新のための新しいデータを取得する
    /// - Returns: 更新されたバナー、カテゴリ、おすすめアイテムのタプル
    func fetchUpdatedData() async throws -> (banners: [Banner], categories: [Category], recommendedItems: [Item]) {
        // 非同期処理をシミュレート（実際のアプリではAPIリクエスト）
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒の遅延
        
        // 更新データを返す
        return (
            banners: createUpdatedBanners(),
            categories: createUpdatedCategories(),
            recommendedItems: createUpdatedRecommendedItems()
        )
    }
    
    /// ページ単位でカテゴリを取得する
    /// - Parameters:
    ///   - page: ページ番号（1から開始）
    ///   - pageSize: 1ページあたりのカテゴリ数
    /// - Returns: 取得したカテゴリの配列と次のページがあるかどうかの情報
    func fetchCategories(page: Int, pageSize: Int = 2) async throws -> (categories: [Category], hasNextPage: Bool) {
        // 非同期処理をシミュレート（実際のアプリではAPIリクエスト）
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒の遅延
        
        // ページングを簡略化する - 全カテゴリリストから指定ページのデータを取得する方式に変更
        let allCategories = getAllCategories()
        
        // 配列全体のサイズを確認
        let totalCategories = allCategories.count
        
        // ページングの計算
        let startIndex = (page - 1) * pageSize
        
        // 範囲外のページリクエストの場合は空配列を返す
        if startIndex >= totalCategories {
            print("⚠️ ページ範囲外: startIndex(\(startIndex)) >= totalCategories(\(totalCategories))")
            return (categories: [], hasNextPage: false)
        }
        
        // 現在のページ用のカテゴリを抽出
        let endIndex = min(startIndex + pageSize, totalCategories)
        let pageCategories = Array(allCategories[startIndex..<endIndex])
        
        print("📊 ページング情報: ページ\(page) - \(startIndex)から\(endIndex-1)の\(pageCategories.count)件を返します")
        
        // 次のページがあるかどうかを判定
        let hasNextPage = endIndex < totalCategories
        
        return (categories: pageCategories, hasNextPage: hasNextPage)
    }
    
    // MARK: - データ生成ヘルパーメソッド
    
    /// 初期バナーデータの作成
    private func createInitialBanners() -> [Banner] {
        return [
            Banner(title: "春の新商品特集", imageName: "spring_banner", backgroundColor: .systemPink),
            Banner(title: "限定セール実施中", imageName: "sale_banner", backgroundColor: .systemBlue),
            Banner(title: "新規会員登録キャンペーン", imageName: "campaign_banner", backgroundColor: .systemGreen)
        ]
    }
    
    /// 更新バナーデータの作成
    private func createUpdatedBanners() -> [Banner] {
        return [
            Banner(title: "夏のセール", imageName: "summer_sale", backgroundColor: .systemTeal),
            Banner(title: "新商品入荷", imageName: "new_items", backgroundColor: .systemIndigo)
        ]
    }
    
    /// 初期カテゴリデータの作成
    private func createInitialCategories() -> [Category] {
        // フルーツカテゴリ
        let fruitCategory = createFruitCategory()
        
        // スポーツカテゴリ
        let sportsCategory = createSportsCategory()
        
        // 旅行カテゴリ
        let travelCategory = createTravelCategory()
        
        // 初期カテゴリのセットを返す
        return [fruitCategory, sportsCategory, travelCategory]
    }
    
    /// フルーツカテゴリの作成
    private func createFruitCategory() -> Category {
        let subCategories = [
            SubCategory(name: "国産フルーツ", items: [
                Item(title: "りんご", color: .systemRed),
                Item(title: "バナナ", color: .systemYellow)
            ]),
            SubCategory(name: "輸入フルーツ", items: [
                Item(title: "オレンジ", color: .systemOrange),
                Item(title: "ぶどう", color: .purple)
            ])
        ]
        
        return Category(name: "フルーツ", subCategories: subCategories)
    }
    
    /// スポーツカテゴリの作成
    private func createSportsCategory() -> Category {
        let subCategories = [
            SubCategory(name: "ボールスポーツ", items: [
                Item(title: "サッカー", color: .systemGreen),
                Item(title: "野球", color: .systemBlue),
                Item(title: "バスケットボール", color: .systemOrange)
            ]),
            SubCategory(name: "ラケットスポーツ", items: [
                Item(title: "テニス", color: .systemYellow),
                Item(title: "バドミントン", color: .systemCyan)
            ])
        ]
        
        return Category(name: "スポーツ", subCategories: subCategories)
    }
    
    /// 旅行カテゴリの作成
    private func createTravelCategory() -> Category {
        let subCategories = [
            SubCategory(name: "国内旅行", items: [
                Item(title: "京都", color: .systemRed),
                Item(title: "北海道", color: .systemCyan),
                Item(title: "沖縄", color: .systemBlue)
            ]),
            SubCategory(name: "海外旅行", items: [
                Item(title: "ハワイ", color: .systemTeal),
                Item(title: "イタリア", color: .systemGreen),
                Item(title: "フランス", color: .systemIndigo)
            ])
        ]
        
        return Category(name: "旅行", subCategories: subCategories)
    }
    
    /// 更新カテゴリデータの作成
    private func createUpdatedCategories() -> [Category] {
        // 家電カテゴリ
        let applianceCategory = createApplianceCategory()
        
        // 季節カテゴリ
        let seasonCategory = createSeasonCategory()
        
        // 更新カテゴリのセットを返す
        return [applianceCategory, seasonCategory]
    }
    
    /// 家電カテゴリの作成
    private func createApplianceCategory() -> Category {
        let subCategories = [
            SubCategory(name: "キッチン家電", items: [
                Item(title: "冷蔵庫", color: .systemBlue),
                Item(title: "電子レンジ", color: .systemGray),
                Item(title: "トースター", color: .systemOrange)
            ]),
            SubCategory(name: "AV機器", items: [
                Item(title: "テレビ", color: .systemPurple),
                Item(title: "ゲーム機", color: .systemGreen),
                Item(title: "スピーカー", color: .systemRed)
            ])
        ]
        
        return Category(name: "家電製品", subCategories: subCategories)
    }
    
    /// 季節カテゴリの作成
    private func createSeasonCategory() -> Category {
        let subCategories = [
            SubCategory(name: "春", items: [
                Item(title: "桜", color: .systemPink),
                Item(title: "チューリップ", color: .systemRed)
            ]),
            SubCategory(name: "夏", items: [
                Item(title: "ひまわり", color: .systemYellow),
                Item(title: "海", color: .systemBlue)
            ]),
            SubCategory(name: "秋", items: [
                Item(title: "紅葉", color: .systemOrange),
                Item(title: "きのこ", color: .systemBrown)
            ])
        ]
        
        return Category(name: "季節", subCategories: subCategories)
    }
    
    /// 追加のカテゴリデータを作成（3ページ目用）
    private func createAdditionalCategories() -> [Category] {
        // 本カテゴリ
        let bookCategory = createBookCategory()
        
        // ペットカテゴリ
        let petCategory = createPetCategory()
        
        // 追加カテゴリのセットを返す
        return [bookCategory, petCategory]
    }
    
    /// 書籍カテゴリの作成
    private func createBookCategory() -> Category {
        let subCategories = [
            SubCategory(name: "ビジネス書", items: [
                Item(title: "マーケティング入門", color: .systemBlue),
                Item(title: "リーダーシップ論", color: .systemRed),
                Item(title: "投資の基本", color: .systemGreen)
            ]),
            SubCategory(name: "小説", items: [
                Item(title: "ミステリー", color: .systemPurple),
                Item(title: "SF", color: .systemTeal),
                Item(title: "ファンタジー", color: .systemIndigo)
            ])
        ]
        
        return Category(name: "本", subCategories: subCategories)
    }
    
    /// ペットカテゴリの作成
    private func createPetCategory() -> Category {
        let subCategories = [
            SubCategory(name: "犬", items: [
                Item(title: "チワワ", color: .systemYellow),
                Item(title: "柴犬", color: .systemOrange),
                Item(title: "ゴールデンレトリバー", color: .systemBrown)
            ]),
            SubCategory(name: "猫", items: [
                Item(title: "スコティッシュフォールド", color: .systemGray),
                Item(title: "シャム猫", color: .systemBlue),
                Item(title: "アメリカンショートヘア", color: .systemGreen)
            ])
        ]
        
        return Category(name: "ペット", subCategories: subCategories)
    }
    
    /// 初期おすすめアイテムの作成
    private func createInitialRecommendedItems() -> [Item] {
        return [
            Item(title: "おすすめ1", color: .systemPink),
            Item(title: "おすすめ2", color: .systemBlue),
            Item(title: "おすすめ3", color: .systemGreen),
            Item(title: "おすすめ4", color: .systemOrange),
            Item(title: "おすすめ5", color: .systemPurple)
        ]
    }
    
    /// 更新おすすめアイテムの作成
    private func createUpdatedRecommendedItems() -> [Item] {
        return [
            Item(title: "季節限定品", color: .systemYellow),
            Item(title: "ベストセラー", color: .systemRed),
            Item(title: "新発売商品", color: .systemGreen),
            Item(title: "割引商品", color: .systemBlue)
        ]
    }
    
    /// すべてのカテゴリデータを順番に格納した配列を返す
    private func getAllCategories() -> [Category] {
        var allCategories: [Category] = []
        
        // 初期カテゴリ（ページ1用）
        allCategories.append(contentsOf: createInitialCategories())
        
        // 追加カテゴリ（ページ2用）
        allCategories.append(contentsOf: createUpdatedCategories())
        
        // さらに追加カテゴリ（ページ3用）
        allCategories.append(contentsOf: createAdditionalCategories())
        
        return allCategories
    }
    
    /// データ取得エラー
    enum DataProviderError: Error {
        case networkError
        case invalidData
        case unknown
    }
} 