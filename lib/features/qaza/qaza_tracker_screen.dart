import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../providers/theme_provider.dart';

class QazaTrackerScreen extends StatefulWidget {
  const QazaTrackerScreen({super.key});

  @override
  State<QazaTrackerScreen> createState() => _QazaTrackerScreenState();
}

class _QazaTrackerScreenState extends State<QazaTrackerScreen> {
  static const _prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  final _counts = <String, int>{};

  @override
  void initState() {
    super.initState();
    for (final p in _prayers) {
      _counts[p] = StorageService.prefs.getInt('qaza_$p') ?? 0;
    }
  }

  Future<void> _increment(String prayer) async {
    setState(() => _counts[prayer] = (_counts[prayer] ?? 0) + 1);
    await StorageService.prefs.setInt('qaza_$prayer', _counts[prayer]!);
  }

  Future<void> _decrement(String prayer) async {
    if ((_counts[prayer] ?? 0) <= 0) return;
    setState(() => _counts[prayer] = (_counts[prayer] ?? 0) - 1);
    await StorageService.prefs.setInt('qaza_$prayer', _counts[prayer]!);
  }

  int get _total => _counts.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Qaza Tracker',
            style: TextStyle(color: theme.textPrimary)),
        backgroundColor: theme.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _DebtCard(total: _total, theme: theme),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _prayers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final prayer = _prayers[i];
                  return _QazaRow(
                    prayerName: prayer,
                    count: _counts[prayer] ?? 0,
                    theme: theme,
                    onIncrement: () => _increment(prayer),
                    onDecrement: () => _decrement(prayer),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Total debt card ─────────────────────────────────────────────────────────

class _DebtCard extends StatelessWidget {
  final int total;
  final AppThemeData theme;

  const _DebtCard({required this.total, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Total Qaza Debt',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w200,
            ),
          ),
          Text(
            total == 1 ? 'prayer remaining' : 'prayers remaining',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Per-prayer row ──────────────────────────────────────────────────────────

class _QazaRow extends StatelessWidget {
  final String prayerName;
  final int count;
  final AppThemeData theme;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QazaRow({
    required this.prayerName,
    required this.count,
    required this.theme,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              prayerName,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _RoundButton(
            icon: Icons.remove,
            onTap: count > 0 ? onDecrement : null,
            theme: theme,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: 36,
              child: Text(
                '$count',
                style: TextStyle(
                  color: count > 0 ? theme.accent : theme.textSecondary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _RoundButton(
            icon: Icons.add,
            onTap: onIncrement,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final AppThemeData theme;

  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled
              ? theme.accent.withAlpha(35)
              : theme.textSecondary.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled ? theme.accent : theme.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
