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
        setupNavigationBar()
        
        // 初期データのロード
        Task {
            await loadInitialData()
        }
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
        sectionTypes = [.banner] // バナーセクションから開始
        
        // 各カテゴリをセクションタイプに追加
        for category in categories {
            sectionTypes.append(.category(category))
        }
        
        // おすすめセクションを追加（指定位置に挿入するか、指定がなければ末尾に追加）
        if let index = recommendationIndex, index > 0, index < sectionTypes.count {
            // 指定された位置が有効な場合、その位置に挿入
            sectionTypes.insert(.recommendations, at: index)
        } else {
            // 指定された位置が無効な場合、または指定がない場合は末尾に追加
            sectionTypes.append(.recommendations)
        }
        
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
    
    // ナビゲーションバーの設定
    private func setupNavigationBar() {
        title = "多階層カテゴリサンプル"
        
        // リロードボタンを追加
        let reloadButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(reloadDataAction)
        )
        navigationItem.rightBarButtonItem = reloadButton
    }
    
    // データをリロードするアクション（UIボタンから呼ばれる非同期メソッド）
    @objc private func reloadDataAction() {
        Task {
            await reloadData()
        }
    }
    
    // データをリロードする実装
    private func reloadData() async {
        // ローディング開始（UIの操作はメインスレッドで自動的に行われる）
        activityIndicator.startAnimating()
        
        do {
            // DataProviderから更新データを取得
            let data = try await dataProvider.fetchUpdatedData()
            
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
            showErrorAlert(message: "データの更新に失敗しました: \(error.localizedDescription)")
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


