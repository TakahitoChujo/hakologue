# ロードマップ

## v1.0 (MVP) - 完了

全機能 (F1〜F9) 実装済み。テスト・セキュリティ対応完了。

---

## v1.1 - セキュリティ強化 & 安定化

優先度順に実施。

### 必須 (Must)

| タスク | 概要 | 対象ファイル |
|--------|------|-------------|
| Hive 暗号化 | DB をアプリ固有キーで暗号化 | `database_service.dart`, `main.dart` |
| EXIF メタデータ除去 | 写真保存時に位置情報等を削除 | `photo_service.dart` |
| パストラバーサル防止 | 写真パスの正規化・検証 | `photo_service.dart` |
| DB エラーハンドリング | 全 CRUD 操作に try-catch 追加 | `database_service.dart` |

### 推奨 (Should)

| タスク | 概要 | 対象ファイル |
|--------|------|-------------|
| 一時ファイルクリーンアップ | 箱作成キャンセル時の写真削除 | `box_add_screen.dart` |
| 写真パス検証 | 表示前にファイル存在確認 | `photo_preview.dart`, `box_detail_screen.dart` |
| エラー表示の統一 | SnackBar によるエラーメッセージ統一 | 各 screen |
| ローディング状態の統一 | 非同期処理中の UI フィードバック | 各 screen |

### 任意 (Nice to have)

| タスク | 概要 |
|--------|------|
| ProGuard / R8 難読化設定 | Android リリースビルド用 |
| アプリアイコン設定 | flutter_launcher_icons で生成 |
| スプラッシュ画面 | flutter_native_splash で設定 |

---

## v2.0 - 家族共有 & UX 強化

仕様書 2.2節に基づく将来機能。

| 機能 | 概要 |
|------|------|
| 家族共有 | QRコード経由でプロジェクト共有 |
| 通知機能 | 開封リマインダー |
| データエクスポート | CSV / PDF 出力 |
| 多言語対応 | 英語サポート |
| ダークモード | システム設定連動 |
| Firebase 連携 | Crashlytics + Analytics |
| SSL/TLS 通信 | 共有機能のサーバー通信暗号化 |
