//
//  CollectionViewDataSource.swift
//  StructuredCollectionViewSample
//
//

import UIKit

// カスタムセルのimport
// 注意: 実際のプロジェクトでは、モジュール構造に応じて適切なimport文を使用してください

/// UICollectionViewDiffableDataSourceの設定と管理を担当するクラス
class CollectionViewDataSource {
    
    /// データソースの識別子
    enum CellReuseID: String {
        /// サブカテゴリセル
        case subCategory = "SubCategoryCell"
        /// アイテムセル
        case item = "ItemCell"
        /// バナーセル
        case banner = "BannerCell"
    }
    
    /// DiffableDataSource
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, CellItem>!
    
    /// カテゴリのリスト
    private(set) var categories: [Category] = []
    
    /// バナーのリスト
    private var banners: [Banner] = []
    
    /// おすすめアイテムのリスト
    private var recommendedItems: [Item] = []
    
    /// セクションタイプを保持する配列
    private var sectionTypes: [SectionType] = []
    
    /// コレクションビューの参照
    private weak var collectionView: UICollectionView?
    
    /// デフォルトのおすすめセクションの位置（nil = 最後）
    private let defaultRecommendationIndex: Int? = 2
    
    /// 指定されたコレクションビューに対してデータソースを設定
    /// - Parameter collectionView: 設定対象のコレクションビュー
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        configureDataSource(collectionView: collectionView)
        
        // 初期レイアウト
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    /// データソースを設定
    /// - Parameter collectionView: 設定対象のコレクションビュー
    private func configureDataSource(collectionView: UICollectionView) {
        registerCells()
        configureCellProvider(collectionView: collectionView)
        configureSupplementaryViewProvider()
    }
    
    /// セルとヘッダーを登録
    /// - Parameter collectionView: 設定対象のコレクションビュー
    private func registerCells() {
        // 型安全なセル登録の代わりに文字列ベースの登録を使用
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseID.subCategory.rawValue)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseID.item.rawValue)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseID.banner.rawValue)
        
        // ヘッダーとフッターの登録
        collectionView?.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView"
        )
        
        collectionView?.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "LoadingFooterView"
        )
    }
    
    /// セルプロバイダーの設定
    /// - Parameter collectionView: 設定対象のコレクションビュー
    private func configureCellProvider(collectionView: UICollectionView) {
        dataSource = UICollectionViewDiffableDataSource<Section, CellItem>(collectionView: collectionView) { 
            [weak self] (collectionView: UICollectionView, indexPath: IndexPath, cellItem: CellItem) -> UICollectionViewCell? in
            
            switch cellItem {
            case .subCategory(let subCategory):
                return self?.configureSubCategoryCell(collectionView: collectionView, indexPath: indexPath, subCategory: subCategory)
                
            case .item(let item, _):
                return self?.configureItemCell(collectionView: collectionView, indexPath: indexPath, item: item)
                
            case .banner(let banner):
                return self?.configureBannerCell(collectionView: collectionView, indexPath: indexPath, banner: banner)
            }
        }
    }
    
    /// サブカテゴリセルの設定
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    ///   - subCategory: 表示するサブカテゴリ
    /// - Returns: 設定済みのセル
    private func configureSubCategoryCell(collectionView: UICollectionView, indexPath: IndexPath, subCategory: SubCategory) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellReuseID.subCategory.rawValue,
            for: indexPath)
        
        // セルの設定
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // タイトルラベルの設定
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .darkText
        titleLabel.text = subCategory.name
        
        // サブタイトルラベルの設定
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = .gray
        subtitleLabel.text = "\(subCategory.items.count)個のアイテム"
        
        // スタックビューの設定
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        
        cell.contentView.addSubview(stackView)
        
        // レイアウト制約の設定
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])
        
        return cell
    }
    
    /// アイテムセルの設定
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    ///   - item: 表示するアイテム
    /// - Returns: 設定済みのセル
    private func configureItemCell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellReuseID.item.rawValue,
            for: indexPath)
        
        // セルの設定
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = item.color
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        // タイトルラベルの設定
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.text = item.title
        
        cell.contentView.addSubview(titleLabel)
        
        // レイアウト制約の設定
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
    
    /// バナーセルの設定
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    ///   - banner: 表示するバナー
    /// - Returns: 設定済みのセル
    private func configureBannerCell(collectionView: UICollectionView, indexPath: IndexPath, banner: Banner) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellReuseID.banner.rawValue,
            for: indexPath)
        
        // セルの設定
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = banner.backgroundColor
        cell.layer.cornerRadius = 12
        cell.clipsToBounds = true
        
        // 影の設定
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
        cell.layer.shadowOpacity = 0.2
        
        // タイトルラベルの設定
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.text = banner.title
        
        cell.contentView.addSubview(titleLabel)
        
        // レイアウト制約の設定
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
    
    /// 補助ビュー（ヘッダーとフッター）のプロバイダーを設定
    private func configureSupplementaryViewProvider() {
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let self = self else { return nil }
            
            if kind == UICollectionView.elementKindSectionHeader {
                return self.configureHeaderView(collectionView: collectionView, indexPath: indexPath)
            } else if kind == UICollectionView.elementKindSectionFooter {
                return collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "LoadingFooterView",
                    for: indexPath)
            }
            
            return nil
        }
    }
    
    /// ヘッダービューの設定
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    /// - Returns: 設定済みのヘッダービュー
    private func configureHeaderView(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView? {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView",
            for: indexPath)
        
        // ヘッダービューの設定
        headerView.subviews.forEach { $0.removeFromSuperview() }
        
        // セクションタイトルの取得
        guard let section = dataSource.sectionIdentifier(for: indexPath.section) else {
            return headerView
        }
        
        // タイトルラベルの設定
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .darkText
        titleLabel.text = section.title
        
        headerView.addSubview(titleLabel)
        
        // レイアウト制約の設定
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    /// 初期データをロード
    /// - Parameters:
    ///   - banners: 表示するバナーの配列
    ///   - categories: 表示するカテゴリの配列
    ///   - recommendedItems: 表示するおすすめアイテムの配列
    func applyInitialData(banners: [Banner], categories: [Category], recommendedItems: [Item]) {
        // 受け取ったデータを保存
        self.banners = banners
        self.categories = categories
        self.recommendedItems = recommendedItems
        
        // セクションタイプを更新
        updateSectionTypes(with: categories, recommendationIndex: defaultRecommendationIndex)
        
        // UIを更新
        updateSections(animate: true)
        
        // レイアウトを更新
        updateLayout()
    }
    
    /// カテゴリ情報からセクションタイプを更新
    /// - Parameters:
    ///   - categories: カテゴリ配列
    ///   - recommendationIndex: おすすめセクションの表示位置（nil=末尾）
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
    }
    
    /// レイアウトを更新
    private func updateLayout() {
        // レイアウトを更新
        collectionView?.collectionViewLayout = CollectionViewLayoutFactory.createCompositionalLayout(sectionTypes: sectionTypes)
    }
    
    /// セクションとアイテムを更新する
    /// - Parameters:
    ///   - animate: アニメーションの有無
    private func updateSections(animate: Bool = false) {
        // 新しいスナップショットを作成
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellItem>()
        
        // セクションタイプに基づいてセクションとアイテムを追加
        for sectionType in sectionTypes {
            switch sectionType {
            case .banner:
                if !banners.isEmpty {
                    let bannerSection = Section(banner: ())
                    snapshot.appendSections([bannerSection])
                    
                    // バナーアイテムを追加
                    let bannerItems = banners.map { CellItem.banner($0) }
                    snapshot.appendItems(bannerItems, toSection: bannerSection)
                }
                
            case .category(let category):
                // セクションを作成
                let section = Section(category: category)
                snapshot.appendSections([section])
                
                // サブカテゴリとアイテムをセルアイテムとして追加
                for subCategory in category.subCategories {
                    // まずサブカテゴリのセルを追加
                    let subCategoryCell = CellItem.subCategory(subCategory)
                    snapshot.appendItems([subCategoryCell], toSection: section)
                    
                    // 続いて、そのサブカテゴリに含まれるアイテムを追加
                    let itemCells = subCategory.items.map { CellItem.item($0, subCategory) }
                    snapshot.appendItems(itemCells, toSection: section)
                }
                
            case .recommendations:
                if !recommendedItems.isEmpty {
                    let recommendedSection = Section(recommendations: ())
                    snapshot.appendSections([recommendedSection])
                    
                    // おすすめアイテムを追加（共通化のためSubCategoryをnilに設定）
                    let recommendedCells = recommendedItems.map { CellItem.item($0, nil) }
                    snapshot.appendItems(recommendedCells, toSection: recommendedSection)
                }
            }
        }
        
        // スナップショットを適用
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
    /// すべてのカテゴリを新しいカテゴリで置き換える
    /// - Parameters:
    ///   - categories: 新しいカテゴリの配列
    ///   - animate: アニメーションの有無
    func replaceAllCategories(_ categories: [Category], animate: Bool = true) {
        // カテゴリを完全に置き換え
        self.categories = categories
        
        // セクションタイプを更新
        updateSectionTypes(with: categories)
        
        // UIを更新
        updateSections(animate: animate)
        
        // レイアウトを更新
        updateLayout()
    }
    
    /// 既存のカテゴリを保持しつつ、新しいカテゴリを末尾に追加する
    /// - Parameters:
    ///   - categories: 追加するカテゴリの配列
    ///   - animate: アニメーションの有無
    func appendCategories(_ categories: [Category], animate: Bool = true) {
        // 既存のカテゴリと重複しない新しいカテゴリのみを追加
        var addedCategories: [Category] = []
        
        for newCategory in categories {
            let exists = self.categories.contains { $0.name == newCategory.name }
            if !exists {
                self.categories.append(newCategory)
                addedCategories.append(newCategory)
            }
        }
        
        // 追加したカテゴリの情報をログに出力
        print("📦 カテゴリ追加: \(addedCategories.count)件を追加しました")
        
        if !addedCategories.isEmpty {
            // セクションタイプを更新
            updateSectionTypes(with: self.categories)
            
            // 新しいセクションをスナップショットに追加
            var snapshot = dataSource.snapshot()
            
            // 新しいカテゴリ用のセクションを作成して追加
            for newCategory in addedCategories {
                let newSection = Section(category: newCategory)
                
                // 常に最後にセクションを追加
                snapshot.appendSections([newSection])
                
                // サブカテゴリとアイテムをセルアイテムとして追加
                for subCategory in newCategory.subCategories {
                    // サブカテゴリのセルを追加
                    let subCategoryCell = CellItem.subCategory(subCategory)
                    snapshot.appendItems([subCategoryCell], toSection: newSection)
                    
                    // そのサブカテゴリに含まれるアイテムを追加
                    let itemCells = subCategory.items.map { CellItem.item($0, subCategory) }
                    snapshot.appendItems(itemCells, toSection: newSection)
                }
            }
            
            // 更新されたスナップショットを適用
            print("🔄 新しいカテゴリ \(addedCategories.map { $0.name }) をUIに反映します")
            dataSource.apply(snapshot, animatingDifferences: animate)
            
            // レイアウトを更新
            updateLayout()
        }
    }
    
    /// バナーをリロードする
    /// - Parameters:
    ///   - banners: 新しいバナー配列
    ///   - animate: アニメーションの有無
    func reloadBanners(_ banners: [Banner], animate: Bool = true) {
        self.banners = banners
        updateSections(animate: animate)
    }
    
    /// おすすめアイテムをリロードする
    /// - Parameters:
    ///   - items: 新しいおすすめアイテム配列
    ///   - animate: アニメーションの有無
    func reloadRecommendedItems(_ items: [Item], animate: Bool = true) {
        self.recommendedItems = items
        updateSections(animate: animate)
    }
    
    /// フッターのローディング状態を更新する
    /// - Parameter isLoading: ロード中かどうか
    func updateFooterLoadingState(_ isLoading: Bool) {
        // 表示中のフッタービューを取得して状態を更新
        if let collectionView = collectionView {
            let footerViews = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter)
            for footerView in footerViews {
                // LoadingFooterViewを型安全に使えないため、タグとプロパティで対応
                if footerView.subviews.first is UIActivityIndicatorView {
                    let indicator = footerView.subviews.first as? UIActivityIndicatorView
                    if isLoading {
                        indicator?.startAnimating()
                    } else {
                        indicator?.stopAnimating()
                    }
                    print("🔄 フッターのローディング状態を変更: \(isLoading)")
                }
            }
        }
    }
} 
