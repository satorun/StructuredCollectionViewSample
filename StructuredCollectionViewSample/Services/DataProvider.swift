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
        let fruitSubs = [
            SubCategory(name: "国産フルーツ", items: [
                Item(title: "りんご", color: .systemRed),
                Item(title: "バナナ", color: .systemYellow)
            ]),
            SubCategory(name: "輸入フルーツ", items: [
                Item(title: "オレンジ", color: .systemOrange),
                Item(title: "ぶどう", color: .purple)
            ])
        ]
        
        // スポーツカテゴリ
        let sportsSubs = [
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
        
        // 旅行カテゴリ
        let travelSubs = [
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
        
        // カテゴリを設定
        return [
            Category(name: "フルーツ", subCategories: fruitSubs),
            Category(name: "スポーツ", subCategories: sportsSubs),
            Category(name: "旅行", subCategories: travelSubs)
        ]
    }
    
    /// 更新カテゴリデータの作成
    private func createUpdatedCategories() -> [Category] {
        // 家電カテゴリ
        let applianceSubs = [
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
        
        // 季節カテゴリ
        let seasonSubs = [
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
        
        // 新しいカテゴリを作成
        return [
            Category(name: "家電製品", subCategories: applianceSubs),
            Category(name: "季節", subCategories: seasonSubs)
        ]
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
    
    /// データ取得エラー
    enum DataProviderError: Error {
        case networkError
        case invalidData
        case unknown
    }
} 