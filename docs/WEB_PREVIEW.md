# Web プレビュー手順

CocoaPods 未インストール等で iOS シミュレーターが使えない場合、Web 版で UI 確認が可能。

## 前提

- Web プラットフォーム追加済み (`flutter create --platforms=web .`)
- `flutter_secure_storage` が Web 非対応のため、`database_service.dart` に `kIsWeb` 分岐あり（Web 版は DB 暗号化スキップ）

## 起動手順

```bash
# Web サーバーモードで起動（iPhone からもアクセス可能）
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

## アクセス方法

| デバイス | URL |
|---------|-----|
| PC ブラウザ | http://localhost:8080 |
| iPhone / Android（同一 Wi-Fi） | http://<Mac の IP>:8080 |

Mac の IP 確認:

```bash
ipconfig getifaddr en0
```

## 制限事項

- カメラ撮影・写真選択は動作しない
- QR コードスキャンは動作しない
- DB 暗号化は無効（UI 確認専用）
- スプラッシュ画面はネイティブ機能のため表示されない

## 停止

ターミナルで `q` を入力、または `Ctrl+C`。
