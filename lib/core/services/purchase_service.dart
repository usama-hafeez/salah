import 'package:in_app_purchase/in_app_purchase.dart';
import 'storage_service.dart';

class PurchaseService {
  // Product IDs — must match exactly what is created in Play Console
  static const proThemesId = 'pro_themes_lifetime';
  static const removeAdsId = 'remove_ads_lifetime';
  static const proAnnualId = 'pro_annual';
  static const proMonthlyId = 'pro_monthly';

  static final _iap = InAppPurchase.instance;

  static Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    // Listen to purchase updates
    _iap.purchaseStream.listen(_handlePurchaseUpdates);

    // Restore previous purchases on startup (Business Rule #10)
    await _iap.restorePurchases();
  }

  static void _handlePurchaseUpdates(
      List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await StorageService.setIsPro(true);
        await _iap.completePurchase(purchase);
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
