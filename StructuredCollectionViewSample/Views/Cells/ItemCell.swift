//
//  ItemCell.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/04.
//

import UIKit

/// アイテム表示用のカスタムセル
class ItemCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ItemCell"
    
    /// アイテムのタイトルを表示するラベル
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
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
        backgroundColor = nil
    }
    
    private func setupCell() {
        layer.cornerRadius = 8
        clipsToBounds = true
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    /// セルの内容を設定する
    /// - Parameter item: 表示するアイテム
    func configure(with item: Item) {
        titleLabel.text = item.title
        backgroundColor = item.color
    }
} 