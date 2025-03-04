//
//  BannerCell.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/04.
//

import UIKit

/// バナー表示用のカスタムセル
class BannerCell: UICollectionViewCell {
    
    static let reuseIdentifier = "BannerCell"
    
    /// バナーのタイトルを表示するラベル
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
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
        // 角丸スタイルの設定
        layer.cornerRadius = 12
        clipsToBounds = true
        
        // セルに影を付ける
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        
        // タイトルラベルを追加
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    /// セルの内容を設定する
    /// - Parameter banner: 表示するバナー
    func configure(with banner: Banner) {
        titleLabel.text = banner.title
        backgroundColor = banner.backgroundColor
    }
} 