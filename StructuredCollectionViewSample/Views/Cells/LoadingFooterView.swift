//
//  LoadingFooterView.swift
//  StructuredCollectionViewSample
//
//  Created by satoru.nishimura on 2025/03/04.
//

import UIKit

/// ページング用のローディングフッタービュー
class LoadingFooterView: UICollectionReusableView {
    
    static let reuseIdentifier = "LoadingFooterView"
    
    /// アクティビティインジケーター
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
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemGray
        
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    /// ローディング状態を設定
    /// - Parameter isLoading: ロード中かどうか
    func setLoading(_ isLoading: Bool) {
        print("🔄 フッターのローディング状態を変更: \(isLoading)")
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
} 