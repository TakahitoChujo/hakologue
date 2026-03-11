# テストレポート

最終実行日: 2026-02-27 (v1.1)
結果: **52/52 PASSED**

## テスト一覧

### モデルテスト (21 tests)

| ファイル | テスト数 | 内容 |
|----------|---------|------|
| `test/models/move_project_test.dart` | 7 | 作成・JSON変換・completedAt・デフォルト値 |
| `test/models/moving_box_test.dart` | 7 | 作成・JSON変換・photoIds・isOpened |
| `test/models/item_test.dart` | 7 | 作成・JSON変換・quantity・note |

### サービステスト (1 test)

| ファイル | テスト数 | 内容 |
|----------|---------|------|
| `test/services/search_service_test.dart` | 1 | SearchResult モデルテスト |

### データテスト (4 tests)

| ファイル | テスト数 | 内容 |
|----------|---------|------|
| `test/data/room_presets_test.dart` | 4 | プリセット数・必須部屋・emoji・重複なし |

### ウィジェットテスト (25 tests)

| ファイル | テスト数 | 内容 |
|----------|---------|------|
| `test/widgets/progress_bar_test.dart` | 4 | 0%・50%・100%表示・テキスト |
| `test/widgets/box_card_test.dart` | 7 | 箱名・部屋・アイテム数・開封状態・タップ |
| `test/widgets/room_filter_chips_test.dart` | 4 | チップ表示・選択・コールバック |
| `test/widgets/item_input_row_test.dart` | 8 | 入力・送信・クリア・空文字防止 |
| `test/widgets/qr_display_test.dart` | 2 | QRコード・箱名表示 |

### アプリテスト (1 test)

| ファイル | テスト数 | 内容 |
|----------|---------|------|
| `test/widget_test.dart` | 1 | アプリ起動確認 |

## カバレッジ

| カテゴリ | テスト対象 | 未テスト |
|----------|-----------|---------|
| モデル | 全3モデル | - |
| サービス | SearchService | DatabaseService, PhotoService (実機依存) |
| ウィジェット | 5/6 ウィジェット | photo_preview (カメラ依存) |
| 画面 | - | 全画面 (Hive/Navigator依存) |
| プロバイダー | - | 全プロバイダー (Hive依存) |

## v1.1 品質確認

| チェック | 結果 |
|----------|------|
| `flutter analyze` | 0 issues |
| `flutter test` | 52/52 passed |
| 既存テスト回帰 | なし |
| v1.0 → v1.1 マイグレーション | コード上対応済み (暗号化マイグレーション) |

## 今後の改善

- [ ] DatabaseService のモックテスト追加
- [ ] PhotoService のモックテスト追加 (EXIF除去・パス検証)
- [ ] Provider テスト追加 (ProviderContainer 利用)
- [ ] Screen テスト追加 (mocktail でサービスモック)
- [ ] Integration テスト作成 (実機 E2E)
- [ ] テストカバレッジ計測 (flutter test --coverage)
