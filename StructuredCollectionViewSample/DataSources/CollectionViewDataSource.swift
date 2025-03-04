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
    private var categories: [Category] = []
    
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
        
        // 背景色を目立たせる
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.systemBackground
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
        backgroundView.layer.shadowOpacity = 0.1
        backgroundView.layer.shadowRadius = 2
        cell.backgroundView = backgroundView
        
        // 選択時の背景色
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.systemGray6
        selectedBackgroundView.layer.cornerRadius = 10
        cell.selectedBackgroundView = selectedBackgroundView
        
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
        
        // おすすめセクションに表示されるアイテムかどうかを判断
        // この例では単純に判断できないため、
        // より良い実装では、CellItemにセクション情報を持たせるなどの工夫が必要
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers
        if indexPath.section < sectionIdentifiers.count {
            let section = sectionIdentifiers[indexPath.section]
            if case .recommendations = section.type {
                // おすすめアイテムの場合は星マークなどの装飾を追加
                let starView = UIImageView(image: UIImage(systemName: "star.fill"))
                starView.tintColor = .systemYellow
                starView.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(starView)
                
                NSLayoutConstraint.activate([
                    starView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                    starView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
                    starView.widthAnchor.constraint(equalToConstant: 20),
                    starView.heightAnchor.constraint(equalToConstant: 20)
                ])
            }
        }
        
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
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "HeaderView",
                for: indexPath)
            
            // 既存のサブビューをクリア
            headerView.subviews.forEach { $0.removeFromSuperview() }
            
            // ヘッダーにラベルを追加
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.boldSystemFont(ofSize: 18)
            
            // 現在のスナップショットからセクションを取得
            guard let sections = self?.dataSource.snapshot().sectionIdentifiers,
                  indexPath.section < sections.count else {
                label.text = "不明なセクション"
                return headerView
            }
            
            label.text = sections[indexPath.section].title
            headerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            
            return headerView
        }
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