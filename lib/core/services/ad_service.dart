import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'storage_service.dart';

class AdService {
  // TEST IDs — replace with real IDs before Play Store submission
  static const _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // REAL IDs — uncomment and replace before release
  // static const _bannerAdUnitId = 'YOUR_REAL_BANNER_ID';
  // static const _interstitialAdUnitId = 'YOUR_REAL_INTERSTITIAL_ID';

  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static bool _bannerLoaded = false;
  static DateTime? _lastInterstitialShown;

  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  /// Load banner ad. Returns null for Pro users.
  static Future<BannerAd?> loadBanner() async {
    if (StorageService.isPro) return null;

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _bannerLoaded = true,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          _bannerLoaded = false;
        },
      ),
    );

    await _bannerAd!.load();
    return _bannerAd;
  }

  /// Pre-load interstitial so it is ready when needed.
  static Future<void> preloadInterstitial() async {
    if (StorageService.isPro) return;

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Show interstitial — max once per 10 minutes (Business Rule #9).
  static void showInterstitial() {
    if (StorageService.isPro) return;
    if (_interstitialAd == null) return;

    // Frequency cap
    if (_lastInterstitialShown != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialShown!);
      if (elapsed.inMinutes < 10) return;
    }

    _lastInterstitialShown = DateTime.now();
    _interstitialAd!.show();
    _interstitialAd = null;
    preloadInterstitial();
  }

  static bool get isBannerLoaded => _bannerLoaded && _bannerAd != null;
  static BannerAd? get bannerAd => _bannerAd;

  static void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerLoaded = false;
  }
}
