# アーキテクチャ

## 技術スタック

| レイヤー | 技術 | バージョン |
|----------|------|-----------|
| フレームワーク | Flutter | 3.27.4 |
| 言語 | Dart | 3.6.2 |
| 状態管理 | Riverpod (flutter_riverpod) | 2.6.1 |
| ローカルDB | Hive + hive_flutter | 2.2.3 / 1.1.0 |
| QR生成 | qr_flutter | 4.1.0 |
| QRスキャン | mobile_scanner | 6.0.2 |
| カメラ | image_picker | 1.1.2 |
| ファイルパス | path_provider | 2.1.5 |
| UUID | uuid | 4.5.1 |
| 共有 | share_plus | 10.1.0 |
| 広告 | google_mobile_ads | 5.3.0 |

## ディレクトリ構成

```
lib/
├── main.dart                  # エントリポイント (Hive初期化 + ProviderScope)
├── app.dart                   # MaterialApp (Material 3, blue theme)
│
├── models/                    # データモデル (JSON serialization)
│   ├── move_project.dart      #   プロジェクト
│   ├── moving_box.dart        #   箱
│   └── item.dart              #   アイテム
│
├── constants/                 # 定数
│   ├── app_colors.dart        #   カラー (#4A90D9 primary)
│   ├── dimensions.dart        #   スペーシング
│   └── ad_constants.dart      #   広告ID・プラットフォーム分岐
│
├── data/                      # 静的データ
│   └── room_presets.dart      #   部屋カテゴリ 8種
│
├── services/                  # ビジネスロジック
│   ├── database_service.dart  #   Hive CRUD (4 boxes)
│   ├── photo_service.dart     #   写真撮影・保存
│   ├── search_service.dart    #   アイテム検索
│   └── ad_service.dart        #   AdMob SDK初期化・バナー管理
│
├── providers/                 # Riverpod プロバイダー
│   ├── database_provider.dart #   サービスプロバイダー
│   ├── project_provider.dart  #   CurrentProjectNotifier
│   ├── box_provider.dart      #   BoxList/BoxItems/Filter
│   ├── search_provider.dart   #   検索クエリ・結果
│   └── ad_provider.dart       #   広告サービス・表示フラグ
│
├── widgets/                   # 再利用可能ウィジェット
│   ├── box_card.dart
│   ├── progress_bar.dart
│   ├── room_filter_chips.dart
│   ├── qr_display.dart
│   ├── item_input_row.dart
│   ├── photo_preview.dart
│   └── ad_banner_widget.dart  #   AdMob バナー広告
│
└── screens/                   # 画面
    ├── home_screen.dart       #   メイン (進捗 + 箱一覧)
    ├── box_add_screen.dart    #   箱作成
    ├── box_detail_screen.dart #   箱詳細
    ├── qr_scan_screen.dart    #   QRスキャン
    ├── search_screen.dart     #   検索
    └── settings_screen.dart   #   設定
```

## データフロー

```
┌──────────┐    JSON     ┌──────────────┐   Provider    ┌──────────┐
│   Hive   │ ◄────────► │   Services   │ ◄──────────► │ Notifier │
│  (4 box) │            │  DB/Photo/   │              │ Provider │
└──────────┘            │   Search     │              └────┬─────┘
                        └──────────────┘                   │
                                                      watch/read
                                                           │
                                                    ┌──────▼─────┐
                                                    │   Screen   │
                                                    │  / Widget  │
                                                    └────────────┘
```

## Hive ストア構成

| Box名 | キー | 値 | 用途 |
|--------|------|----|------|
| `projects` | UUID | MoveProject JSON | プロジェクト管理 |
| `boxes` | UUID | MovingBox JSON | 箱管理 |
| `items` | UUID | Item JSON | アイテム管理 |
| `settings` | String | dynamic | アプリ設定 |

## QRコード仕様

- フォーマット: `hakologue://box/{uuid}`
- UUID形式: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (小文字hex)
- スキャン時: UUID正規表現バリデーション → プロジェクト所有権確認 → 箱詳細へ遷移

## 写真保存

- パス: `{appDocDir}/photos/{projectId}/{boxId}_{timestamp}.jpg`
- 圧縮: 最大 1280px, JPEG 80%
- ソース: カメラ撮影 or ギャラリー選択
