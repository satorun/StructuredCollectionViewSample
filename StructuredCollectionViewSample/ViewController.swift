//
//  ViewController.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/03.
//

import UIKit

// アイテムモデル
struct Item: Hashable {
    let id: UUID
    let title: String
    let color: UIColor
    
    init(title: String, color: UIColor) {
        self.id = UUID()
        self.title = title
        self.color = color
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

// セクションの種類を定義するenum
enum Section: Int, CaseIterable {
    case grid
    case list
    case horizontal
    
    var title: String {
        switch self {
        case .grid:
            return "グリッド"
        case .list:
            return "リスト"
        case .horizontal:
            return "水平スクロール"
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // DiffableDataSourceの定義
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    // セルの識別子
    private enum CellReuseID: String {
        case basic = "BasicCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セルの登録
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseID.basic.rawValue)
        
        // ヘッダービューの登録
        collectionView.register(UICollectionReusableView.self, 
                               forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, 
                               withReuseIdentifier: "HeaderView")
        
        // コレクションビューのレイアウト設定
        setupCollectionViewLayout()
        
        // データソースの設定
        configureDataSource()
        
        // 初期データをロード
        applyInitialSnapshots()
    }
    
    private func setupCollectionViewLayout() {
        collectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let section = Section(rawValue: sectionIndex)
            
            switch section {
            case .grid:
                return self.createGridSection()
            case .list:
                return self.createListSection()
            case .horizontal:
                return self.createHorizontalSection()
            case .none:
                return self.createGridSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    private func createGridSection() -> NSCollectionLayoutSection {
        // アイテムサイズ定義
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        // グループサイズ定義
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // セクション定義
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        // セクションヘッダー追加
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createHorizontalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6),
                                              heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func configureDataSource() {
        // セルプロバイダーの設定
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { 
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellReuseID.basic.rawValue,
                for: indexPath) as? UICollectionViewCell else {
                    return nil
            }
            
            // セルの内容を設定
            var config = UIListContentConfiguration.cell()
            config.text = item.title
            cell.contentConfiguration = config
            cell.backgroundColor = item.color
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true
            
            return cell
        }
        
        // ヘッダービュープロバイダーの設定
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
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
            label.text = Section(rawValue: indexPath.section)?.title
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
    
    private func applyInitialSnapshots() {
        // 各セクションのデータを作成
        let gridItems = (0..<10).map { Item(title: "グリッド \($0)", color: .systemBlue) }
        let listItems = (0..<10).map { Item(title: "リスト \($0)", color: .systemGreen) }
        let horizontalItems = (0..<10).map { Item(title: "水平 \($0)", color: .systemOrange) }
        
        // スナップショットを作成
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.grid, .list, .horizontal])
        snapshot.appendItems(gridItems, toSection: .grid)
        snapshot.appendItems(listItems, toSection: .list)
        snapshot.appendItems(horizontalItems, toSection: .horizontal)
        
        // スナップショットを適用
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

