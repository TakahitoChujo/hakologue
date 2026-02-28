import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdConstants {
  // テスト用 App ID（本番リリース前に実際のIDに差し替え）
  static String get appId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544~3347511713';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544~1458002511';
    return '';
  }

  // テスト用 Banner Unit ID
  static String get bannerUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    return '';
  }

  static bool get isAdSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}
