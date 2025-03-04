//
//  ViewController.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // データソースを管理するオブジェクト
    private var collectionViewDataSource: CollectionViewDataSource!
    
    // セクションタイプを保持する配列
    private var sectionTypes: [SectionType] = []
    
    // ローディングインジケーター
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    // データプロバイダー（サーバー通信のモック）
    private let dataProvider = DataProvider.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ローディングインジケーターの設定
        setupActivityIndicator()
        
        // セクションの定義
        setupSectionTypes()
        setupCollectionView()
        
        // 初期データのロード
        Task {
            await loadInitialData()
        }
        
        // テスト用のカテゴリ更新ボタンを追加
        setupTestUpdateButton()
    }
    
    // アクティビティインジケーターの設定
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // 初期データをロード
    private func loadInitialData() async {
        // ローディング開始（UIの操作はメインスレッドで自動的に行われる）
        activityIndicator.startAnimating()
        
        do {
            // DataProviderからデータを取得
            let data: (banners: [Banner], categories: [Category], recommendedItems: [Item]) = try await dataProvider.fetchAllData()
            
            // ViewControllerは暗黙的に@MainActorなのでMainActor.runは不要
            // ローディング終了
            activityIndicator.stopAnimating()
            
            // データをデータソースに設定
            self.collectionViewDataSource.applyInitialSnapshots(
                banners: data.banners,
                categories: data.categories,
                recommendedItems: data.recommendedItems
            )
            
            // セクションタイプを更新（おすすめセクションは2番目の位置に表示）
            self.updateSectionTypes(with: data.categories, recommendationIndex: 2)
            
            // セクション構成を更新
            self.collectionViewDataSource.updateSectionConfiguration(sectionTypes: self.sectionTypes)
        } catch {
            // エラー処理（ViewControllerは暗黙的に@MainActorなのでMainActor.runは不要）
            // ローディング終了
            activityIndicator.stopAnimating()
            
            // エラーアラートを表示
            showErrorAlert(message: "データの取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // カテゴリ情報からセクションタイプを更新
    private func updateSectionTypes(with categories: [Category], recommendationIndex: Int? = nil) {
        // 現在のおすすめセクションのインデックスを保持
        // (もしあれば、既存のレイアウト構造を維持するため)
        let existingRecommendIndex = sectionTypes.firstIndex { type in
            if case .recommendations = type { return true }
            return false
        }
        
        // バナーセクションがあるかどうかを確認
        let hasBanner = sectionTypes.contains { type in
            if case .banner = type { return true }
            return false
        }
        
        // セクションタイプを再構築
        var newSectionTypes: [SectionType] = []
        
        // バナーがあれば追加
        if hasBanner {
            newSectionTypes.append(.banner)
        } else {
            // デフォルトのバナーセクションから開始
            newSectionTypes.append(.banner)
        }
        
        // 各カテゴリをセクションタイプに追加
        for category in categories {
            newSectionTypes.append(.category(category))
        }
        
        // おすすめセクションを追加（既存の位置または指定位置に挿入、それ以外は末尾に追加）
        let targetIndex = existingRecommendIndex ?? recommendationIndex
        
        if let index = targetIndex, index > 0, index < newSectionTypes.count {
            // 指定または既存の位置が有効な場合、その位置に挿入
            newSectionTypes.insert(.recommendations, at: index)
        } else {
            // 位置指定がない場合は末尾に追加
            newSectionTypes.append(.recommendations)
        }
        
        // 新しいセクションタイプを保存
        sectionTypes = newSectionTypes
        
        // レイアウトを更新
        collectionView.collectionViewLayout = CollectionViewLayoutFactory.createCompositionalLayout(sectionTypes: sectionTypes)
    }
    
    // セクションタイプの設定
    private func setupSectionTypes() {
        // 初期化時は空のセクションタイプのリストを作成
        // 実際のデータはloadInitialDataで取得してから設定する
        sectionTypes = []
    }
    
    // コレクションビューの設定
    private func setupCollectionView() {
        // コレクションビューのレイアウト設定
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        // データソースの設定
        collectionViewDataSource = CollectionViewDataSource(collectionView: collectionView)
        
        // スクロールデリゲートの設定
        collectionView.delegate = self
    }
    
    // エラーアラートを表示
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "エラー",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        
        present(alert, animated: true)
    }
    
    /// 特定のカテゴリを更新する
    /// - Parameter categories: 更新するカテゴリの配列
    func updateCategories(_ categories: [Category]) {
        // カテゴリを更新 - 古いデータを保持せず完全に置き換える
        collectionViewDataSource.replaceAllCategories(categories, animate: true)
        
        // セクションタイプを新しいカテゴリで再構築
        updateSectionTypes(with: categories)
        
        // セクション構成を更新
        collectionViewDataSource.updateSectionConfiguration(sectionTypes: self.sectionTypes)
    }
    
    // 既存のセクションタイプを保持しつつ、カテゴリのみを更新したセクションタイプを作成
    private func createUpdatedSectionTypes(with newCategories: [Category]) -> [SectionType] {
        var updatedTypes: [SectionType] = []
        
        // 元のセクションタイプの順序を維持しつつ、カテゴリ部分だけを更新
        for type in sectionTypes {
            switch type {
            case .category(let existingCategory):
                // 更新対象のカテゴリがあるか確認
                if let updatedCategory = newCategories.first(where: { $0.name == existingCategory.name }) {
                    // 名前が一致するカテゴリがあれば、更新されたカテゴリを使用
                    updatedTypes.append(.category(updatedCategory))
                } else {
                    // それ以外の場合は既存のカテゴリをそのまま使用
                    updatedTypes.append(type)
                }
            case .banner, .recommendations:
                // バナーとおすすめはそのまま維持
                updatedTypes.append(type)
            }
        }
        
        // 元のセクションタイプにない新しいカテゴリを追加
        for newCategory in newCategories {
            let exists = sectionTypes.contains { type in
                if case .category(let cat) = type, cat.name == newCategory.name {
                    return true
                }
                return false
            }
            
            // 既存のセクションタイプにないカテゴリは追加
            if !exists {
                // おすすめセクションの前に追加するか、なければ最後に追加
                if let recommendIndex = updatedTypes.firstIndex(where: { 
                    if case .recommendations = $0 { return true }
                    return false 
                }) {
                    updatedTypes.insert(.category(newCategory), at: recommendIndex)
                } else {
                    updatedTypes.append(.category(newCategory))
                }
            }
        }
        
        // 更新されたセクションタイプを保存
        self.sectionTypes = updatedTypes
        
        return updatedTypes
    }
    
    // テスト用の更新ボタンを設定
    private func setupTestUpdateButton() {
        let updateButton = UIButton(type: .system)
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.setTitle("カテゴリ更新", for: .normal)
        updateButton.backgroundColor = .systemBlue
        updateButton.setTitleColor(.white, for: .normal)
        updateButton.layer.cornerRadius = 8
        updateButton.addTarget(self, action: #selector(updateCategoryButtonTapped), for: .touchUpInside)
        
        view.addSubview(updateButton)
        
        NSLayoutConstraint.activate([
            updateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            updateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            updateButton.widthAnchor.constraint(equalToConstant: 150),
            updateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func updateCategoryButtonTapped() {
        // テスト用にカテゴリを更新
        Task {
            do {
                // ローディング開始
                activityIndicator.startAnimating()
                
                // 更新用のデータを取得（実際のアプリではAPIから特定カテゴリだけ取得するなど）
                let updatedData = try await dataProvider.fetchUpdatedData()
                
                // ローディング終了
                activityIndicator.stopAnimating()
                
                // カテゴリ名の確認（デバッグ用）
                print("更新前のカテゴリ: \(self.collectionViewDataSource.categories.map { $0.name })")
                print("更新するカテゴリ: \(updatedData.categories.map { $0.name })")
                
                // カテゴリを更新
                updateCategories(updatedData.categories)
                
                // デバッグ用ログ
                print("カテゴリ更新完了: \(updatedData.categories.count)件")
                print("更新後のセクション: \(self.sectionTypes.count)件")
            } catch {
                // エラー処理
                activityIndicator.stopAnimating()
                showErrorAlert(message: "カテゴリの更新に失敗しました: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 必要に応じて実装
    }
}

// 配列の安全なインデックスアクセス用拡張
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


