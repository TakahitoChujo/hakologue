import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';

class AdService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (!AdConstants.isAdSupported) return;
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  BannerAd createBannerAd({
    required AdSize adSize,
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    final bannerAd = BannerAd(
      adUnitId: AdConstants.bannerUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
    bannerAd.load();
    return bannerAd;
  }
}
