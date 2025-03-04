//
//  ViewController.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    /// UICollectionViewDataSourceを管理するオブジェクト
    private var collectionViewDataSource: CollectionViewDataSource!
    
    // ページング用の変数
    private var currentPage = 1
    private var isLoading = false
    private var hasNextPage = true
    
    // ローディングインジケーター
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    // フッターローディングインジケーター
    private lazy var footerActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGray
        return indicator
    }()
    
    // データプロバイダー（サーバー通信のモック）
    private let dataProvider = DataProvider.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ローディングインジケーターの設定
        setupActivityIndicator()
        
        setupCollectionView()
        
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
    
    // コレクションビューの設定
    private func setupCollectionView() {
        // データソースの設定
        collectionViewDataSource = CollectionViewDataSource(collectionView: collectionView)
        
        // スクロールデリゲートの設定
        collectionView.delegate = self
        
        // フッターの登録は不要（データソース内で登録済み）
    }
    
    // 初期データをロード
    private func loadInitialData() async {
        // ローディング開始
        activityIndicator.startAnimating()
        
        do {
            // 初期データを取得（1ページ目）
            let data: (banners: [Banner], categories: [Category], recommendedItems: [Item]) = try await dataProvider.fetchAllData()
            
            // ページング情報をリセット
            currentPage = 1
            hasNextPage = true
            
            // ローディング終了
            activityIndicator.stopAnimating()
            
            // データをデータソースに設定
            self.collectionViewDataSource.applyInitialData(
                banners: data.banners,
                categories: data.categories,
                recommendedItems: data.recommendedItems
            )
        } catch {
            // エラー処理
            activityIndicator.stopAnimating()
            
            // エラーアラートを表示
            showErrorAlert(message: "データの取得に失敗しました: \(error.localizedDescription)")
        }
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
    
    // 次のページのカテゴリを読み込む
    private func loadNextPage() async {
        // すでに読み込み中か次のページがない場合は何もしない
        guard !isLoading, hasNextPage else { return }
        
        // ロード状態を更新
        isLoading = true
        
        do {
            // 次のページを取得
            let nextPage = currentPage + 1
            print("🔄 ページ \(nextPage) の読み込みを開始します")
            let result = try await dataProvider.fetchCategories(page: nextPage)
            
            // ロード状態を更新
            isLoading = false
            
            // データがない場合は終了
            if result.categories.isEmpty {
                print("❌ ページ \(nextPage) にはデータがありません")
                hasNextPage = false
                // 最後のページに到達したらインジケーターを非表示
                updateFooterVisibility(visible: false)
                return
            }
            
            // 次のページがあるかどうかを更新
            hasNextPage = result.hasNextPage
            
            // 最後のページを読み込んだ場合はインジケーターを非表示
            if !hasNextPage {
                print("📄 最後のページに到達しました")
                updateFooterVisibility(visible: false)
            }
            
            // 現在のページを更新
            currentPage = nextPage
            
            // カテゴリ名の確認（デバッグ用）
            print("✅ ページ \(currentPage) のデータ取得成功: \(result.categories.count)件")
            
            // カテゴリを追加
            collectionViewDataSource.appendCategories(result.categories, animate: true)
            
        } catch {
            // エラー処理
            isLoading = false
            print("❌ カテゴリの取得に失敗しました: \(error.localizedDescription)")
            
            // エラー時はローディングインジケーターを非表示
            updateFooterVisibility(visible: false)
        }
    }
    
    // フッターインジケーターの表示/非表示を制御
    private func updateFooterVisibility(visible: Bool) {
        DispatchQueue.main.async {
            if visible {
                self.footerActivityIndicator.startAnimating()
            } else {
                self.footerActivityIndicator.stopAnimating()
            }
            
            // フッタービューの更新
            // LoadingFooterViewの型は使用せず、視覚的なフィードバックのみ提供
            print("フッタービューの表示状態を更新: \(visible)")
            
            // カスタムクラスの型情報がないため、フッタービューの視覚的な更新は
            // CollectionViewDataSourceに任せる処理に変更
            self.collectionViewDataSource.updateFooterLoadingState(visible)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // コレクションビューの最後のセルが表示された時に次のページを読み込む
        let lastSectionIndex = collectionView.numberOfSections - 1
        if lastSectionIndex >= 0 {
            let lastItemIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
            if indexPath.section == lastSectionIndex && indexPath.item == lastItemIndex {
                // 最後のセルが表示されたら、次のページを読み込む
                Task {
                    await loadNextPage()
                }
            }
        }
    }
    
    // スクロール時のイベント処理
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // スクロールが下部に近づいた時に次のページを読み込む
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        // コンテンツの下部から100ポイント以内にスクロールしたら次のページをロード
        if offsetY > contentHeight - height - 100 {
            // すでに読み込み中の場合は何もしない
            guard !isLoading else { return }
            
            // 最後のページに到達した場合、フッターインジケーターを非表示にして終了
            if !hasNextPage {
                print("📜 最後のページに到達しました - ローディングインジケーターを非表示にします")
                updateFooterVisibility(visible: false)
                return
            }
            
            print("📜 スクロールが検出されました - 次のページを読み込みます")
            
            // フッターインジケーターを表示
            updateFooterVisibility(visible: true)
            
            // 次のページを読み込む
            Task {
                await loadNextPage()
            }
        }
    }
}

// 配列の安全なインデックスアクセス用拡張
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


