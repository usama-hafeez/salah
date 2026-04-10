import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../premium/paywall_screen.dart';
import '../tasbih/tasbih_screen.dart';
import '../ramadan/ramadan_screen.dart';
import '../qaza/qaza_tracker_screen.dart';
import 'theme_picker_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Settings & More',
            style: TextStyle(color: theme.textPrimary)),
        backgroundColor: theme.primary,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _SectionHeader(label: 'Islamic Tools', theme: theme),
          _NavTile(
            icon: Icons.autorenew_rounded,
            title: 'Tasbih Counter',
            subtitle: 'SubhanAllah · Alhamdulillah · AllahuAkbar',
            theme: theme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TasbihScreen()),
            ),
          ),
          _NavTile(
            icon: Icons.nightlight_outlined,
            title: 'Ramadan',
            subtitle: 'Sehri & Iftar times, 30-day timetable',
            theme: theme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RamadanScreen()),
            ),
          ),
          _NavTile(
            icon: Icons.format_list_numbered_rounded,
            title: 'Qaza Tracker',
            subtitle: 'Track missed prayers to make up',
            theme: theme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QazaTrackerScreen()),
            ),
          ),
          _SectionHeader(label: 'Settings', theme: theme),
          _ComingSoonTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            theme: theme,
          ),
          _ComingSoonTile(
            icon: Icons.calculate_outlined,
            title: 'Calculation Method',
            theme: theme,
          ),
          _NavTile(
            icon: Icons.palette_outlined,
            title: 'Themes',
            subtitle: 'Choose from 8 themes, including 6 Pro themes',
            theme: theme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemePickerScreen()),
            ),
          ),
          _ComingSoonTile(
            icon: Icons.language_outlined,
            title: 'Language',
            theme: theme,
          ),
          _NavTile(
            icon: Icons.star_outline_rounded,
            title: 'Upgrade to Pro',
            subtitle: 'Remove ads, unlock themes & Qibla compass',
            theme: theme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaywallScreen()),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final AppThemeData theme;

  const _SectionHeader({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: theme.accent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final AppThemeData theme;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.accent.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: theme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final AppThemeData theme;

  const _ComingSoonTile({
    required this.icon,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.textSecondary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, color: theme.textSecondary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.textSecondary.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Phase 10',
              style: TextStyle(color: theme.textSecondary, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
