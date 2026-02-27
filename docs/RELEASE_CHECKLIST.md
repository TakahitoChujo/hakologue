# ストアリリース前チェックリスト

## ビルド準備

- [x] flutter analyze: 0 issues
- [x] flutter test: 全テスト合格
- [x] バージョン番号更新 (`pubspec.yaml` の version) → 1.1.0+2
- [x] アプリアイコン設定 (flutter_launcher_icons)
- [x] スプラッシュ画面設定 (flutter_native_splash)

## Android

- [x] `android/app/build.gradle` の applicationId 確認 (`com.hakologue.hakologue`)
- [ ] minSdkVersion / targetSdkVersion 確認
- [ ] リリース署名キー作成 (keystore)
- [ ] `android/app/build.gradle` に signingConfigs 設定
- [x] ProGuard / R8 難読化設定
- [ ] `flutter build appbundle --release`
- [ ] 実機で動作確認 (カメラ・QR・写真)

## iOS

- [ ] Xcode で Bundle Identifier 確認
- [ ] Apple Developer アカウント設定
- [ ] Provisioning Profile 作成
- [x] Info.plist の権限記述確認 (カメラ・写真)
- [ ] `flutter build ipa --release`
- [ ] 実機で動作確認 (カメラ・QR・写真)

## ストア提出

### Google Play
- [ ] ストア掲載情報 (タイトル・説明・スクリーンショット)
- [ ] プライバシーポリシー URL
- [ ] コンテンツレーティング質問回答
- [ ] App Bundle アップロード
- [ ] 内部テスト → クローズドテスト → オープンテスト → 本番

### App Store
- [ ] App Store Connect でアプリ登録
- [ ] スクリーンショット (6.7" / 5.5" / iPad)
- [ ] プライバシーポリシー URL
- [ ] App Privacy 情報入力
- [ ] TestFlight で内部テスト
- [ ] 審査提出

## リリース後

- [ ] クラッシュ監視設定 (Firebase Crashlytics 推奨)
- [ ] ユーザーフィードバック収集体制
- [x] ~~v1.1 セキュリティ強化の着手~~ → 完了
