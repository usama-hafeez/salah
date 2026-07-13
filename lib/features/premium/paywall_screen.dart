import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../../core/services/purchase_service.dart';
import '../../core/services/storage_service.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/theme_provider.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  List<ProductDetails> _products = [];
  bool _loadingProducts = true;
  bool _purchasing = false;
  String? _purchaseError;

  @override
  void initState() {
    super.initState();
    _fetchPrices();
  }

  Future<void> _fetchPrices() async {
    setState(() => _loadingProducts = true);
    try {
      _products = await PurchaseService.getProductDetails();
    } catch (_) {
      _products = [];
    }
    if (mounted) setState(() => _loadingProducts = false);
  }

  String _priceFor(String productId, String fallback) {
    try {
      final match = _products.firstWhere((p) => p.id == productId);
      return match.price;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _buy(Future<void> Function() action) async {
    setState(() {
      _purchasing = true;
      _purchaseError = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _purchaseError = 'Purchase failed. Please try again.');
    }
    if (mounted) setState(() => _purchasing = false);
  }

  Future<void> _restore() async {
    setState(() {
      _purchasing = true;
      _purchaseError = null;
    });
    try {
      await PurchaseService.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _purchaseError = 'Restore failed. Please try again.');
    }
    if (mounted) setState(() => _purchasing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    final isPro = context.watch<PurchaseProvider>().isPro;

    // If user just completed a purchase, show success and allow dismiss
    if (isPro) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(
          backgroundColor: theme.primary,
          foregroundColor: theme.textPrimary,
          elevation: 0,
        ),
        body: _ProActiveView(theme: theme, onDismiss: () => Navigator.pop(context)),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primary,
        foregroundColor: theme.textPrimary,
        title: Text('Upgrade to Pro', style: TextStyle(color: theme.textPrimary)),
        elevation: 0,
      ),
      body: _purchasing
          ? Center(child: CircularProgressIndicator(color: theme.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero
                  _HeroSection(theme: theme),
                  const SizedBox(height: 28),

                  // Feature comparison table
                  _FeatureTable(theme: theme),
                  const SizedBox(height: 28),

                  // Error message
                  if (_purchaseError != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withAlpha(60),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _purchaseError!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Purchase options
                  Text(
                    'CHOOSE YOUR PLAN',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pro Annual — highlighted
                  _PurchaseButton(
                    title: 'Pro Annual',
                    subtitle: 'Best value — full Pro access',
                    price: _loadingProducts
                        ? '...'
                        : _priceFor(PurchaseService.proAnnualId, '\$0.99'),
                    period: '/ year',
                    highlight: true,
                    badge: 'BEST VALUE',
                    theme: theme,
                    onTap: () => _buy(PurchaseService.buyProAnnual),
                  ),
                  const SizedBox(height: 10),

                  // Pro Monthly
                  _PurchaseButton(
                    title: 'Pro Monthly',
                    subtitle: 'Full Pro access, billed monthly',
                    price: _loadingProducts
                        ? '...'
                        : _priceFor(PurchaseService.proMonthlyId, '\$0.49'),
                    period: '/ month',
                    highlight: false,
                    theme: theme,
                    onTap: () => _buy(PurchaseService.buyProMonthly),
                  ),
                  const SizedBox(height: 10),

                  // Remove Ads
                  _PurchaseButton(
                    title: 'Remove Ads',
                    subtitle: 'One-time purchase, ads removed forever',
                    price: _loadingProducts
                        ? '...'
                        : _priceFor(PurchaseService.removeAdsId, '\$0.99'),
                    period: 'one-time',
                    highlight: false,
                    theme: theme,
                    onTap: () => _buy(PurchaseService.buyRemoveAds),
                  ),
                  const SizedBox(height: 10),

                  // Pro Themes
                  _PurchaseButton(
                    title: 'Pro Themes',
                    subtitle: 'Unlock all 8 premium themes forever',
                    price: _loadingProducts
                        ? '...'
                        : _priceFor(PurchaseService.proThemesId, '\$1.99'),
                    period: 'one-time',
                    highlight: false,
                    theme: theme,
                    onTap: () => _buy(PurchaseService.buyProThemes),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: _restore,
                      child: Text(
                        'Restore Purchase',
                        style: TextStyle(color: theme.textSecondary, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Purchases are non-refundable. Subscription renews automatically. Cancel anytime.',
                    style: TextStyle(
                      color: theme.textSecondary.withAlpha(140),
                      fontSize: 10,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Hero section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final dynamic theme;
  const _HeroSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.accent.withAlpha(60),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(Icons.auto_awesome, color: theme.accent, size: 44),
        ),
        const SizedBox(height: 16),
        Text(
          'Unlock the Full Experience',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Get ad-free access to the complete Quran reader,\nQibla compass, and all premium themes.',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Feature comparison table ─────────────────────────────────────────────────

class _FeatureTable extends StatelessWidget {
  final dynamic theme;
  const _FeatureTable({required this.theme});

  static const _features = [
    ('Prayer Times & Countdown', true, true),
    ('Hijri Calendar', true, true),
    ('Tasbih Counter', true, true),
    ('Full Quran Reader', false, true),
    ('Qibla Compass', false, true),
    ('8 Premium Themes', false, true),
    ('Remove All Ads', false, true),
    ('All Future Features', false, true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Feature',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    'Free',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    'Pro',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Feature rows
          ..._features.asMap().entries.map((entry) {
            final i = entry.key;
            final (label, free, pro) = entry.value;
            final isLast = i == _features.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: theme.background.withAlpha(180),
                          width: 1,
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(color: theme.textPrimary, fontSize: 13),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: Center(child: _FeatureIcon(value: free, accent: theme.accent)),
                  ),
                  SizedBox(
                    width: 56,
                    child: Center(child: _FeatureIcon(value: pro, accent: theme.accent)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final bool value;
  final Color accent;
  const _FeatureIcon({required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    return value
        ? Icon(Icons.check_circle_rounded, color: accent, size: 18)
        : Icon(Icons.remove_circle_outline, color: Colors.grey.shade600, size: 18);
  }
}

// ── Purchase button ───────────────────────────────────────────────────────────

class _PurchaseButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String period;
  final bool highlight;
  final String? badge;
  final dynamic theme;
  final VoidCallback onTap;

  const _PurchaseButton({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.highlight,
    required this.theme,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: highlight ? theme.accent : theme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlight ? theme.accent : theme.accent.withAlpha(60),
            width: highlight ? 0 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: highlight ? Colors.black87 : theme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(40),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: highlight
                          ? Colors.black54
                          : theme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    color: highlight ? Colors.black87 : theme.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    color: highlight ? Colors.black54 : theme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pro active confirmation view ──────────────────────────────────────────────

class _ProActiveView extends StatelessWidget {
  final dynamic theme;
  final VoidCallback onDismiss;

  const _ProActiveView({required this.theme, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded,
                  color: Color(0xFF4CAF50), size: 56),
            ),
            const SizedBox(height: 24),
            Text(
              'Pro Active',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you! All Pro features are\nnow unlocked.',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: onDismiss,
              child: const Text('Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
