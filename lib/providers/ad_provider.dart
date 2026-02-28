import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ad_service.dart';

final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

/// 広告を表示するかどうか
/// Phase 3 でプレミアム課金を導入したら:
///   final isPremium = ref.watch(premiumStatusProvider);
///   return !isPremium;
final showAdsProvider = Provider<bool>((ref) {
  return true;
});
