# ロードマップ

## v1.0 (MVP) - 完了

全機能 (F1〜F9) 実装済み。テスト・セキュリティ対応完了。

---

## v1.1 - セキュリティ強化 & 安定化 - 完了

### 必須 (Must) - 全完了

| タスク | 概要 | 対象ファイル | 状態 |
|--------|------|-------------|------|
| Hive 暗号化 | DB をアプリ固有キーで暗号化 + 自動マイグレーション | `database_service.dart`, `main.dart` | 完了 |
| EXIF メタデータ除去 | 写真保存時に位置情報等を削除 | `photo_service.dart` | 完了 |
| パストラバーサル防止 | 写真パスの正規化・検証 | `photo_service.dart` | 完了 |
| DB エラーハンドリング | 全 CRUD 操作に try-catch + DatabaseException | `database_service.dart` | 完了 |

### 推奨 (Should) - 全完了

| タスク | 概要 | 対象ファイル | 状態 |
|--------|------|-------------|------|
| 一時ファイルクリーンアップ | 箱作成キャンセル時の写真削除 | `box_add_screen.dart` | 完了 |
| 写真パス検証 | 表示前にファイル存在確認 | `photo_preview.dart` | 完了 |
| エラー表示の統一 | SnackBar によるエラーメッセージ統一 | `box_detail_screen.dart`, `settings_screen.dart` | 完了 |
| 起動エラー画面 | DB初期化/アプリ初期化失敗時の画面 | `main.dart` | 完了 |

### 任意 (Nice to have) - 一部完了

| タスク | 概要 | 状態 |
|--------|------|------|
| ProGuard / R8 難読化設定 | Android リリースビルド用 | 完了 |
| アプリアイコン設定 | flutter_launcher_icons で生成 | 完了 |
| スプラッシュ画面 | flutter_native_splash で設定 | 完了 |

---

## v1.2 - 広告導入 (Phase 2) - 完了

| タスク | 概要 | 対象ファイル | 状態 |
|--------|------|-------------|------|
| Google AdMob バナー広告 | ホーム画面にバナー広告配置 | `ad_banner_widget.dart`, `home_screen.dart` | 完了 |
| 広告サービス層 | SDK初期化・バナー管理 | `ad_service.dart`, `ad_constants.dart` | 完了 |
| 広告プロバイダー | Riverpod連携 + Phase 3拡張ポイント | `ad_provider.dart` | 完了 |
| プラットフォーム設定 | AndroidManifest / Info.plist / ProGuard | 各設定ファイル | 完了 |
| 部屋フィルターUI修正 | Wrap化で文字見切れ解消 | `room_filter_chips.dart` | 完了 |

**未対応（AdMobアカウント作成後）**: `ad_constants.dart` のテスト用IDを本番IDに差替え

---

## v2.0 - 家族共有 & UX 強化

仕様書 2.2節に基づく将来機能。プレミアムプラン向け。

| 機能 | 概要 |
|------|------|
| 家族共有 | QRコード経由でプロジェクト共有（project_members） |
| デバイス間同期 | Supabase によるクラウド同期 |
| 通知機能 | 開封リマインダー |
| データエクスポート | CSV / PDF 出力 |
| 多言語対応 | 英語サポート |
| ダークモード | システム設定連動 |
| Supabase 連携 | Auth（JWT + 2FA）+ DB + Storage |
| SSL/TLS 通信 | 共有機能のサーバー通信暗号化 |

詳細設計 → [SUPABASE_DESIGN.md](SUPABASE_DESIGN.md)
