import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';
import '../utils/prayer_utils.dart';
import 'storage_service.dart';

class AdService {
  // TEST IDs — replace with real IDs before Play Store submission.
  // Keep these in sync with the AdMob APPLICATION_ID in AndroidManifest.xml.
  static const _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // REAL IDs — uncomment and replace before release
  // static const _bannerAdUnitId = 'YOUR_REAL_BANNER_ID';
  // static const _interstitialAdUnitId = 'YOUR_REAL_INTERSTITIAL_ID';

  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static bool _bannerLoaded = false;
  static DateTime? _lastInterstitialShown;

  /// True while the user is actively reading the Quran. Ads are never shown
  /// while this is set (Business Rule #1). Set by the Quran reader screen.
  static bool quranReadingActive = false;

  /// Supplies the next prayer time so interstitials can be suppressed within
  /// 5 minutes of a prayer (Business Rule #2). Wired once at app startup.
  static DateTime? Function()? nextPrayerTimeProvider;

  /// Tracks per-session interstitial caps (e.g. bookmark save, max 1/session).
  static final Set<String> _sessionShownTags = {};

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
    if (_interstitialAd != null) return; // already loaded

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Whether an interstitial is currently allowed under all business rules.
  static bool _canShowInterstitial() {
    if (StorageService.isPro) return false; // no ads for Pro (Business Rule)
    if (quranReadingActive) return false; // never during Quran reading (#1)

    // Never within 5 minutes of a prayer time (#2).
    final nextPrayer = nextPrayerTimeProvider?.call();
    if (nextPrayer != null &&
        PrayerUtils.isNearPrayerTime(nextPrayer, DateTime.now())) {
      return false;
    }

    // Frequency cap — max once per cooldown window (#9).
    if (_lastInterstitialShown != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialShown!);
      if (elapsed.inMinutes < AppConstants.interstitialCooldownMinutes) {
        return false;
      }
    }
    return true;
  }

  /// Show an interstitial if all business rules allow it.
  ///
  /// Pass a [sessionTag] to enforce a "max once per session" cap for that
  /// placement (e.g. `'bookmark'`). Placements with no tag only respect the
  /// 10-minute cooldown.
  static void showInterstitial({String? sessionTag}) {
    if (!_canShowInterstitial()) return;
    if (sessionTag != null && _sessionShownTags.contains(sessionTag)) return;
    final ad = _interstitialAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        preloadInterstitial();
      },
    );

    _lastInterstitialShown = DateTime.now();
    if (sessionTag != null) _sessionShownTags.add(sessionTag);
    _interstitialAd = null;
    ad.show();
  }

  static bool get isBannerLoaded => _bannerLoaded && _bannerAd != null;
  static BannerAd? get bannerAd => _bannerAd;

  static void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerLoaded = false;
  }
}
