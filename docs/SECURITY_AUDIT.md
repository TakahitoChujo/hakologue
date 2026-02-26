# セキュリティ監査レポート

監査日: 2026-02-27
基準: OWASP Mobile Top 10

## 修正済み (Critical / High)

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

## 未対応 (Medium / Low) → v1.1 で対応予定

### [M1] Hive データベース暗号化
- **リスク**: Medium
- **問題**: DB がプレーンテキストで保存されている
- **対策**: `Hive.openBox()` に暗号化キーを渡す + flutter_secure_storage でキー管理
- **優先度**: v1.1 必須

### [M2] EXIF メタデータ
- **リスク**: Medium
- **問題**: 写真に位置情報等のメタデータが残る
- **対策**: 保存時に EXIF を除去 (image パッケージ利用)
- **優先度**: v1.1 必須

### [M3] パストラバーサル
- **リスク**: Medium
- **問題**: 写真パスに `../` 等が含まれる可能性
- **対策**: パスの正規化 + appDocDir 配下であることを検証
- **優先度**: v1.1 必須

### [M4] DB エラーハンドリング
- **リスク**: Medium
- **問題**: Hive 操作の例外が未捕捉
- **対策**: 全 CRUD に try-catch 追加
- **優先度**: v1.1 必須

### [L1] 一時ファイルクリーンアップ
- **リスク**: Low
- **問題**: 箱作成キャンセル時に撮影済み写真が残る
- **対策**: dispose() で未保存写真を削除
- **優先度**: v1.1 推奨

### [L2] 写真パス検証
- **リスク**: Low
- **問題**: 存在しない写真パスでエラーになる可能性
- **対策**: 表示前に `File.existsSync()` で確認
- **優先度**: v1.1 推奨

### [L3] ProGuard / R8 難読化
- **リスク**: Low
- **問題**: リリースビルドでコードが読み取れる
- **対策**: Android build.gradle に ProGuard ルール設定
- **優先度**: v1.1 任意
