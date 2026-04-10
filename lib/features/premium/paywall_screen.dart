import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/services/purchase_service.dart';

// Full paywall UI is implemented in Phase 9.
// This screen handles the Pro upgrade flow and restoring purchases.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _loading = false;

  Future<void> _buy(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primary,
        foregroundColor: theme.textPrimary,
        title: Text('Upgrade to Pro',
            style: TextStyle(color: theme.textPrimary)),
        elevation: 0,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: theme.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.auto_awesome,
                          color: theme.accent, size: 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Unlock All Features',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get unlimited access to the full Quran reader,\nQibla compass, premium themes, and more.',
                    style:
                        TextStyle(color: theme.textSecondary, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Feature list
                  ..._features(theme),
                  const SizedBox(height: 32),
                  // Purchase buttons
                  _PurchaseButton(
                    label: 'Pro Annual',
                    price: '\$0.99 / year',
                    highlight: true,
                    theme: theme,
                    onTap: () => _buy(PurchaseService.buyProAnnual),
                  ),
                  const SizedBox(height: 12),
                  _PurchaseButton(
                    label: 'Remove Ads',
                    price: '\$0.99 one-time',
                    highlight: false,
                    theme: theme,
                    onTap: () => _buy(PurchaseService.buyRemoveAds),
                  ),
                  const SizedBox(height: 12),
                  _PurchaseButton(
                    label: 'Pro Themes',
                    price: '\$1.99 one-time',
                    highlight: false,
                    theme: theme,
                    onTap: () => _buy(PurchaseService.buyProThemes),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => _buy(PurchaseService.restorePurchases),
                      child: Text(
                        'Restore Purchase',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  List<Widget> _features(dynamic theme) {
    final List<(IconData, String)> items = [
      (Icons.menu_book_outlined, 'Full Quran Reader with Arabic + Translation'),
      (Icons.explore_outlined, 'Qibla Compass'),
      (Icons.palette_outlined, '8 Premium Themes'),
      (Icons.block_outlined, 'Remove All Ads'),
      (Icons.star_border_outlined, 'All Future Features'),
    ];
    return items
        .map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.accent.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.$1, color: theme.accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    item.$2,
                    style:
                        TextStyle(color: theme.textPrimary, fontSize: 14),
                  ),
                ],
              ),
            ))
        .toList();
  }
}

class _PurchaseButton extends StatelessWidget {
  final String label;
  final String price;
  final bool highlight;
  final dynamic theme;
  final VoidCallback onTap;

  const _PurchaseButton({
    required this.label,
    required this.price,
    required this.highlight,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: highlight ? theme.accent : theme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlight ? theme.accent : theme.accent.withAlpha(60),
            width: highlight ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: highlight ? Colors.black87 : theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: highlight ? Colors.black54 : theme.accent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
