import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/purchase_provider.dart';
import '../providers/theme_provider.dart';

/// Gates a Pro-only screen (Business Rule #3).
///
/// If the user is Pro, [child] is shown unchanged. Otherwise a lock screen with
/// an "Upgrade to Pro" call-to-action is shown instead, so Pro content is never
/// rendered for free users. Rebuilds automatically when a purchase completes
/// because it watches [PurchaseProvider].
class PremiumLockWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onUpgrade;
  final String? description;

  const PremiumLockWidget({
    super.key,
    required this.child,
    required this.onUpgrade,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<PurchaseProvider>().isPro;
    if (isPro) return child;

    final theme = context.watch<ThemeProvider>().current;
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primary,
        foregroundColor: theme.textPrimary,
        elevation: 0,
        title: Text('Pro Feature', style: TextStyle(color: theme.textPrimary)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline_rounded,
                    color: theme.accent, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Pro Feature',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description ??
                    'This feature is part of Pro. Upgrade to unlock it.',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accent,
                  foregroundColor: Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: onUpgrade,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Upgrade to Pro',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
