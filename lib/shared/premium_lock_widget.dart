import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/storage_service.dart';
import '../providers/theme_provider.dart';

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
    if (StorageService.isPro) return child;

    final theme = context.watch<ThemeProvider>().current;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(180),
                  Colors.black.withAlpha(220),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.accent.withAlpha(80),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(Icons.lock_rounded, color: theme.accent, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pro Feature',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    description ??
                        'Unlock the full Quran reader with Arabic text,\ntranslations, and bookmarks.',
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accent,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  onPressed: onUpgrade,
                  child: const Text(
                    'Unlock Pro',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: onUpgrade,
                  child: Text(
                    'Restore Purchase',
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
