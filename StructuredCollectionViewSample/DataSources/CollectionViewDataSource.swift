//
//  CollectionViewDataSource.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import UIKit

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
    
    /// 指定されたコレクションビューに対してデータソースを設定
    /// - Parameter collectionView: 設定対象のコレクションビュー
    init(collectionView: UICollectionView) {
        configureDataSource(collectionView: collectionView)
    }
    
    /// データソースを設定
    /// - Parameter collectionView: 設定対象のコレクションビュー
    private func configureDataSource(collectionView: UICollectionView) {
        registerCells(collectionView: collectionView)
        configureCellProvider(collectionView: collectionView)
        configureHeaderProvider()
    }
    
    /// セルとヘッダーを登録
    /// - Parameter collectionView: 設定対象のコレクションビュー
    private func registerCells(collectionView: UICollectionView) {
        // セルの登録
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseID.subCategory.rawValue)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseID.item.rawValue)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseID.banner.rawValue)
        
        // ヘッダーの登録
        collectionView.register(UICollectionReusableView.self,
                               forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                               withReuseIdentifier: "HeaderView")
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
    
    /// サブカテゴリセルの構成
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    ///   - subCategory: 表示するサブカテゴリ
    /// - Returns: 設定されたセル
    private func configureSubCategoryCell(collectionView: UICollectionView, indexPath: IndexPath, subCategory: SubCategory) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellReuseID.subCategory.rawValue,
            for: indexPath) as? UICollectionViewCell else {
                return nil
        }
        
        // サブカテゴリセルの内容を設定 - タイトルスタイルに変更
        var config = UIListContentConfiguration.subtitleCell()
        config.text = subCategory.name
        config.secondaryText = "\(subCategory.items.count)個のアイテム"
        config.textProperties.font = UIFont.boldSystemFont(ofSize: 18)
        config.textProperties.color = UIColor.darkText
        config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 14)
        config.secondaryTextProperties.color = UIColor.systemGray
        
        // 左側のインデントを追加してタイトル感を強調
        config.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        
        cell.contentConfiguration = config
        
        return cell
    }
    
    /// アイテムセルの構成
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    ///   - item: 表示するアイテム
    /// - Returns: 設定されたセル
    private func configureItemCell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellReuseID.item.rawValue,
            for: indexPath) as? UICollectionViewCell else {
                return nil
        }
        
        // アイテムセルの内容を設定
        var config = UIListContentConfiguration.cell()
        config.text = item.title
        config.textProperties.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cell.contentConfiguration = config
        cell.backgroundColor = item.color
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }
    
    /// バナーセルの構成
    /// - Parameters:
    ///   - collectionView: コレクションビュー
    ///   - indexPath: インデックスパス
    ///   - banner: 表示するバナー
    /// - Returns: 設定されたセル
    private func configureBannerCell(collectionView: UICollectionView, indexPath: IndexPath, banner: Banner) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellReuseID.banner.rawValue,
            for: indexPath) as? UICollectionViewCell else {
                return nil
        }
        
        // バナーセルの内容を設定
        var config = UIListContentConfiguration.cell()
        config.text = banner.title
        config.textProperties.font = UIFont.boldSystemFont(ofSize: 18)
        config.textProperties.color = .white
        cell.contentConfiguration = config
        cell.backgroundColor = banner.backgroundColor
        cell.layer.cornerRadius = 12
        cell.clipsToBounds = true
        
        return cell
    }
    
    /// ヘッダープロバイダーの設定
    private func configureHeaderProvider() {
        dataSource.supplementaryViewProvider = { [weak self]
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            // ヘッダービューの作成
            if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "HeaderView",
                    for: indexPath
                )
                
                // セクションのタイトルを取得
                if let sectionIdentifier = self?.dataSource.sectionIdentifier(for: indexPath.section) {
                    self?.configureHeader(headerView: headerView, for: sectionIdentifier)
                }
                
                return headerView
            }
            
            // フッタービューの作成
            if kind == UICollectionView.elementKindSectionFooter {
                return collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "LoadingFooter",
                    for: indexPath
                )
            }
            
            return nil
        }
    }
    
    /// ヘッダービューを設定
    /// - Parameters:
    ///   - headerView: 設定対象のヘッダービュー
    ///   - section: セクション情報
    private func configureHeader(headerView: UICollectionReusableView, for section: Section) {
        // 既存のサブビューをクリア
        headerView.subviews.forEach { $0.removeFromSuperview() }
        
        // ヘッダーにラベルを追加
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = section.title
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
    }
    
    /// 初期データをロード
    /// - Parameters:
    ///   - banners: 表示するバナーの配列
    ///   - categories: 表示するカテゴリの配列
    ///   - recommendedItems: 表示するおすすめアイテムの配列
    func applyInitialSnapshots(banners: [Banner], categories: [Category], recommendedItems: [Item]) {
        // 受け取ったデータを保存
        self.banners = banners
        self.categories = categories
        self.recommendedItems = recommendedItems
        
        // ※注意: このメソッドを呼び出した後、
        // ViewControllerから updateSectionConfiguration を呼び出して
        // 実際のセクションタイプとその順序を設定する必要があります
    }
    
    /// セクションとアイテムを更新する
    /// - Parameters:
    ///   - animate: アニメーションの有無
    ///   - sectionTypes: 表示するセクションタイプの配列（nilの場合は既存の順序を維持）
    private func updateSections(animate: Bool = false, sectionTypes: [SectionType]? = nil) {
        // 新しいスナップショットを作成
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellItem>()
        
        // 渡されたセクションタイプがある場合はそれを使用し、なければデフォルト順序で表示
        let sectionsToDisplay = sectionTypes ?? []
        
        // セクションタイプに基づいてセクションとアイテムを追加
        for sectionType in sectionsToDisplay {
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
    
    /// セクションの構成を更新
    /// - Parameters:
    ///   - sectionTypes: 表示するセクションタイプの配列
    ///   - animate: アニメーションの有無
    func updateSectionConfiguration(sectionTypes: [SectionType], animate: Bool = true) {
        updateSections(animate: animate, sectionTypes: sectionTypes)
    }

    /// カテゴリを更新
    /// - Parameters:
    ///   - categories: 新しいカテゴリの配列
    ///   - animate: アニメーションの有無
    func reloadCategories(_ categories: [Category], animate: Bool = true) {
        self.categories = categories
        
        // ※ このメソッドは updateSectionConfiguration から呼ばれることを想定
        // そうでない場合は既存のセクション順序を維持
        updateSections(animate: animate)
    }
    
    /// カテゴリを更新して対応するセクションを更新する
    /// - Parameters:
    ///   - categories: 更新するカテゴリの配列
    ///   - animate: アニメーションの有無
    func updateCategories(_ categories: [Category], animate: Bool = true) {
        // カテゴリの更新
        for updatedCategory in categories {
            // 既存のカテゴリを更新
            if let index = self.categories.firstIndex(where: { $0.name == updatedCategory.name }) {
                self.categories[index] = updatedCategory
            } else {
                // 存在しないカテゴリは追加
                self.categories.append(updatedCategory)
            }
        }
        
        // 注意: この時点ではUIの更新は行わない
        // ViewControllerが新しいsectionTypesを作成し、
        // updateSectionConfigurationメソッドを呼び出す必要がある
        
        // すぐに更新したい場合は既存のスナップショットを使って部分的に更新することも可能
        var snapshot = dataSource.snapshot()
        
        // 各セクションを個別に更新
        for sectionIdentifier in snapshot.sectionIdentifiers {
            if case .category(let existingCategory) = sectionIdentifier.type {
                // 更新対象のカテゴリを探す
                if let updatedCategory = categories.first(where: { $0.name == existingCategory.name }) {
                    // カテゴリが見つかった場合、そのセクションのアイテムを削除して再追加
                    let oldItems = snapshot.itemIdentifiers(inSection: sectionIdentifier)
                    snapshot.deleteItems(oldItems)
                    
                    // サブカテゴリとアイテムを追加
                    for subCategory in updatedCategory.subCategories {
                        // サブカテゴリセルを追加
                        let subCategoryItem = CellItem.subCategory(subCategory)
                        snapshot.appendItems([subCategoryItem], toSection: sectionIdentifier)
                        
                        // アイテムを追加
                        let itemCells = subCategory.items.map { CellItem.item($0, subCategory) }
                        snapshot.appendItems(itemCells, toSection: sectionIdentifier)
                    }
                }
            }
        }
        
        // 更新されたスナップショットを適用
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
    /// すべてのカテゴリを新しいカテゴリで置き換える
    /// - Parameters:
    ///   - categories: 新しいカテゴリの配列
    ///   - animate: アニメーションの有無
    func replaceAllCategories(_ categories: [Category], animate: Bool = true) {
        // カテゴリを完全に置き換え
        self.categories = categories
        
        // 注意: ここでは更新は行わない
        // ViewControllerがupdateSectionConfigurationを呼び出す必要がある
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
        
        // 新しいセクションをスナップショットに追加
        if !addedCategories.isEmpty {
            var snapshot = dataSource.snapshot()
            
            // 新しいカテゴリ用のセクションを作成して追加（常に最後に追加）
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
} 