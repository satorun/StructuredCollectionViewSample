# 構造的なコレクションビューサンプル

このプロジェクトは、UICollectionViewを使用して構造的なカテゴリデータを表示するモダンなiOSアプリケーションのサンプルです。UICollectionViewCompositionalLayoutを活用し、複雑な階層構造を持つデータを視覚的に分かりやすく表示しています。

## 機能

- **カテゴリ別表示**: 階層化されたカテゴリ構造をモダンなUIで表示
- **バナー表示**: プロモーションやお知らせ用のバナーセクション
- **ページネーション**: スクロールに応じた追加データの自動読み込み
- **動的レイアウト**: 異なるセクションタイプに適したレイアウトの動的切り替え
- **レスポンシブデザイン**: 異なる画面サイズに対応するレイアウト

## アーキテクチャ

プロジェクトは以下の主要コンポーネントで構成されています：

### モデル

モデルは2つのカテゴリに分かれています：

#### ドメインモデル（Models/Domain/）
ビジネスロジックとデータ構造を表現するモデル：
- `Category.swift`: メインカテゴリモデル
- `SubCategory.swift`: サブカテゴリモデル
- `Item.swift`: 商品アイテムモデル
- `Banner.swift`: バナー表示用モデル

#### UIモデル（Models/UI/）
表示ロジックに関わるモデル：
- `Section.swift`: コレクションビューのセクション構造を定義
- `CellItem.swift`: セル表示のための抽象モデル

### データソース

- `CollectionViewDataSource.swift`: UICollectionViewDiffableDataSourceを使用したモダンなデータソース実装

### レイアウト

- `CollectionViewLayoutFactory.swift`: UICollectionViewCompositionalLayoutを生成するファクトリークラス

### サービス

- `DataProvider.swift`: データ取得のためのサービスクラス（APIとの通信をシミュレート）

### ビュー

- `ViewController.swift`: メインビューコントローラー
- Cells/: 各種セルの実装
  - `BannerCell.swift`: バナー表示用セル
  - `SubCategoryCell.swift`: サブカテゴリ表示用セル
  - `ItemCell.swift`: 商品アイテム表示用セル
  - `SectionHeaderView.swift`: セクションヘッダー
  - `LoadingFooterView.swift`: 読み込み中表示用フッター

## 使用技術

- **Swift 5**
- **UIKit**
- **UICollectionViewCompositionalLayout**: モダンなグリッドレイアウト作成
- **UICollectionViewDiffableDataSource**: 効率的なデータ管理と更新
- **Auto Layout**: レスポンシブUIデザイン

## 要件

- iOS 14.0以上
- Xcode 13.0以上

## スクリーンショット

（スクリーンショットを追加する場合はここに配置）

## 学習ポイント

このサンプルプロジェクトは以下の学習に最適です：

- UICollectionViewCompositionalLayoutの実装方法
- 階層的なデータ構造のUI表現
- モダンなiOSアプリのデータフロー設計
- ページネーションの実装
- 複数の異なるセクションタイプの管理

## 備考

このプロジェクトのコードベースの大部分は、Cursor（Claude-3.7-Sonnet）によって生成されています。実装サンプルの提供とともに、AIによるコード生成の実用性を検証する目的も兼ねています。生成されたコードは人間による確認とレビューを経ており、必要に応じて修正や最適化が行われています。

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

