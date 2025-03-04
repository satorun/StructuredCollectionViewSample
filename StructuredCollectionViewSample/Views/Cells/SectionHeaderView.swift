//
//  SectionHeaderView.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/04.
//

import UIKit

/// セクションヘッダー用のカスタムビュー
class SectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "SectionHeaderView"
    
    /// セクションタイトルを表示するラベル
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkText
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    private func setupView() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    /// ヘッダーの内容を設定する
    /// - Parameter title: 表示するタイトル
    func configure(with title: String) {
        titleLabel.text = title
    }
} 