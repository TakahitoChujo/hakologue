# セキュリティ監査レポート

初回監査日: 2026-02-27
v1.1 更新日: 2026-02-27
基準: OWASP Mobile Top 10

## 修正済み (Critical / High) - v1.0

### [C1] QRコードインジェクション - 修正済み
- **リスク**: Critical
- **問題**: QRスキャン時に入力値の検証なし
- **対策**: UUID正規表現バリデーション追加
- **ファイル**: `lib/screens/qr_scan_screen.dart`

### [C2] プロジェクト所有権未確認 - 修正済み
- **リスク**: Critical
- **問題**: 他プロジェクトの箱IDでもアクセス可能
- **対策**: `box.projectId == project.id` 検証追加
- **ファイル**: `lib/screens/qr_scan_screen.dart`

### [C3] main.dart レースコンディション - 修正済み
- **リスク**: Critical
- **問題**: DB初期化完了前にUIがプロバイダーにアクセス
- **対策**: `_initialized` フラグ + ローディング画面
- **ファイル**: `lib/main.dart`

### [H1] 入力値バリデーション不足 - 修正済み
- **リスク**: High
- **問題**: 箱名・アイテム名・数量に上限なし
- **対策**:
  - 箱名: 100文字上限
  - アイテム名: 200文字上限
  - 検索クエリ: 200文字上限
  - 数量: 1〜9999 にクランプ
- **ファイル**: `box_add_screen.dart`, `item_input_row.dart`, `search_screen.dart`

### [H2] 二重保存 - 修正済み
- **リスク**: High
- **問題**: 保存ボタン連打でデータ重複
- **対策**: `_isSaving` ロック + try-catch + ローディングUI
- **ファイル**: `lib/screens/box_add_screen.dart`

### [H3] プラットフォーム権限未設定 - 修正済み
- **リスク**: High
- **問題**: iOS/Android の権限記述が不足
- **対策**:
  - iOS: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`
  - Android: `CAMERA`, `READ_EXTERNAL_STORAGE` (maxSdkVersion=32), `READ_MEDIA_IMAGES`
- **ファイル**: `ios/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml`

---

## 修正済み (Medium / Low) - v1.1

### [M1] Hive データベース暗号化 - 修正済み
- **リスク**: Medium
- **問題**: DB がプレーンテキストで保存されている
- **対策**: `HiveAesCipher` で全ボックスを暗号化。暗号化キーは `flutter_secure_storage` で管理。v1.0 からの自動マイグレーション対応
- **ファイル**: `lib/services/database_service.dart`, `lib/main.dart`

### [M2] EXIF メタデータ - 修正済み
- **リスク**: Medium
- **問題**: 写真に位置情報等のメタデータが残る
- **対策**: `image` パッケージで JPEG 再エンコード（EXIF 除去）。デコード失敗時はフォールバックで元ファイルをコピー
- **ファイル**: `lib/services/photo_service.dart`

### [M3] パストラバーサル - 修正済み
- **リスク**: Medium
- **問題**: 写真パスに `../` 等が含まれる可能性
- **対策**: projectId/boxId に UUID 正規表現バリデーション。保存パスの正規化 + appDocDir 配下であることを検証
- **ファイル**: `lib/services/photo_service.dart`

### [M4] DB エラーハンドリング - 修正済み
- **リスク**: Medium
- **問題**: Hive 操作の例外が未捕捉
- **対策**: 全 CRUD 操作に try-catch 追加。カスタム `DatabaseException` クラスで統一的なエラー伝播。`main.dart` に DB 初期化エラー画面追加
- **ファイル**: `lib/services/database_service.dart`, `lib/main.dart`

### [L1] 一時ファイルクリーンアップ - 修正済み
- **リスク**: Low
- **問題**: 箱作成キャンセル時に撮影済み写真が残る
- **対策**: `dispose()` で `_createdBoxId == null`（未保存）の場合、一時写真ファイルを削除
- **ファイル**: `lib/screens/box_add_screen.dart`

### [L2] 写真パス検証 - 修正済み
- **リスク**: Low
- **問題**: 存在しない写真パスでエラーになる可能性
- **対策**: `File.existsSync()` で存在確認。存在しない場合は `broken_image` プレースホルダーを表示
- **ファイル**: `lib/widgets/photo_preview.dart`

### [L3] ProGuard / R8 難読化 - 修正済み
- **リスク**: Low
- **問題**: リリースビルドでコードが読み取れる
- **対策**: `build.gradle` に `minifyEnabled true` / `shrinkResources true` + ProGuard ルール設定
- **ファイル**: `android/app/build.gradle`, `android/app/proguard-rules.pro`

---

## 未検出の脆弱性

v1.1 時点で Critical / High / Medium の既知脆弱性はすべて対応済み。
