import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'storage_service.dart';

class PurchaseService {
  // Product IDs — must match exactly what is created in Play Console
  static const proThemesId = 'pro_themes_lifetime';
  static const removeAdsId = 'remove_ads_lifetime';
  static const proAnnualId = 'pro_annual';
  static const proMonthlyId = 'pro_monthly';

  static final _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Called whenever Pro status changes (purchased or restored).
  /// Wire this to PurchaseProvider.refresh() after initialization.
  static void Function()? onProStatusChanged;

  static Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    // Cancel any previous subscription so a re-init (hot restart) doesn't
    // leave duplicate listeners that double-process purchase events.
    await _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );

    // Restore previous purchases on startup (Business Rule #10)
    await _iap.restorePurchases();
  }

  /// Cancel the purchase stream subscription. Call on app teardown.
  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  static void _handlePurchaseUpdates(
      List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await StorageService.setIsPro(true);
        await _iap.completePurchase(purchase);
        onProStatusChanged?.call();
      }
      if (purchase.status == PurchaseStatus.error) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  static Future<void> buyProThemes() => _buyProduct(proThemesId);
  static Future<void> buyRemoveAds() => _buyProduct(removeAdsId);
  static Future<void> buyProAnnual() => _buyProduct(proAnnualId);
  static Future<void> buyProMonthly() => _buyProduct(proMonthlyId);

  static Future<void> _buyProduct(String productId) async {
    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) return;

    final purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  static Future<void> restorePurchases() => _iap.restorePurchases();

  /// Fetch live product details from Play Store for paywall display.
  static Future<List<ProductDetails>> getProductDetails() async {
    final response = await _iap.queryProductDetails({
      proThemesId,
      removeAdsId,
      proAnnualId,
      proMonthlyId,
    });
    return response.productDetails;
  }
}
