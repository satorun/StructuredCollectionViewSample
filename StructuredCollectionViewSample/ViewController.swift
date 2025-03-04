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
    
    // セクションタイプを保持する配列
    private var sectionTypes: [SectionType] = []
    
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
        
        // セクションの定義
        setupSectionTypes()
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
            // エラー処理
            activityIndicator.stopAnimating()
            
            // エラーアラートを表示
            showErrorAlert(message: "データの取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // カテゴリ情報からセクションタイプを更新
    private func updateSectionTypes(with categories: [Category], recommendationIndex: Int? = nil) {
        print("🔄 セクションタイプを更新します: カテゴリ数 = \(categories.count)")
        
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
        
        // カテゴリセクションを保持する配列
        var categoryTypes: [SectionType] = []
        
        // 既存のカテゴリを維持
        for type in sectionTypes {
            if case .category = type {
                categoryTypes.append(type)
            }
        }
        
        // 新しいカテゴリを末尾に追加
        for category in categories {
            // 既存のカテゴリと名前が重複していないか確認
            let exists = categoryTypes.contains { type in
                if case .category(let existingCategory) = type, existingCategory.name == category.name {
                    return true
                }
                return false
            }
            
            // 重複していない場合のみ追加
            if !exists {
                categoryTypes.append(.category(category))
            }
        }
        
        // カテゴリセクションを全て追加
        newSectionTypes.append(contentsOf: categoryTypes)
        
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
        
        print("✅ セクションタイプを更新しました: 合計 \(sectionTypes.count)セクション")
        
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
        
        // フッターの登録（次ページ読み込み用のインジケーター）
        collectionView.register(
            LoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "LoadingFooter"
        )
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
    
    /// 既存のカテゴリを保持しつつ、新しいカテゴリを追加する
    /// - Parameter categories: 追加するカテゴリの配列
    func appendCategories(_ categories: [Category]) {
        print("🔍 カテゴリを追加しています: \(categories.map { $0.name })")
        
        // カテゴリを追加 - 改良したappendCategoriesメソッドを使用
        // これによりDataSourceが直接UIを更新する
        collectionViewDataSource.appendCategories(categories, animate: true)
        
        // セクションタイプの配列も更新して整合性を保つ
        updateSectionTypes(with: collectionViewDataSource.categories)
        
        print("✅ appendCategories完了: 現在のカテゴリ数 = \(collectionViewDataSource.categories.count)")
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
    
    /// 次のページのカテゴリを読み込む
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
            print("📊 既存のカテゴリ: \(self.collectionViewDataSource.categories.map { $0.name })")
            print("➕ 追加するカテゴリ: \(result.categories.map { $0.name })")
            
            // カテゴリを追加
            appendCategories(result.categories)
            
            // デバッグ用ログ
            print("📝 ページ \(currentPage) 読み込み完了: 現在 \(self.collectionViewDataSource.categories.count)件")
            print("🔄 更新後のセクション: \(self.sectionTypes.count)件")
            
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
            if let footerView = self.collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter).first as? LoadingFooterView {
                footerView.setLoading(visible)
            }
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

// ページング用のフッタービュー
class LoadingFooterView: UICollectionReusableView {
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setLoading(_ isLoading: Bool) {
        print("🔄 フッターのローディング状態を変更: \(isLoading)")
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}


