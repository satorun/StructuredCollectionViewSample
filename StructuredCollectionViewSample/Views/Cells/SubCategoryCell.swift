//
//  SubCategoryCell.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/04.
//

import UIKit

/// サブカテゴリ表示用のカスタムセル
class SubCategoryCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SubCategoryCell"
    
    /// サブカテゴリのタイトルを表示するラベル
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkText
        return label
    }()
    
    /// アイテム数を表示するラベル
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    /// ラベルを縦に並べるスタックビュー
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    private func setupCell() {
        // スタックビューにラベルを追加
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        // スタックビューをセルに追加
        contentView.addSubview(stackView)
        
        // レイアウト制約を設定
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // 背景色とスタイルを設定
        backgroundColor = .systemBackground
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray5.cgColor
        layer.cornerRadius = 4
    }
    
    /// セルの内容を設定する
    /// - Parameter subCategory: 表示するサブカテゴリ
    func configure(with subCategory: SubCategory) {
        titleLabel.text = subCategory.name
        subtitleLabel.text = "\(subCategory.items.count)個のアイテム"
    }
} 