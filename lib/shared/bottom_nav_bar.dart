import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    // Watch SettingsProvider so labels rebuild when language changes
    context.watch<SettingsProvider>();

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.surface,
      selectedItemColor: theme.accent,
      unselectedItemColor: theme.textSecondary,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.access_time_outlined),
          activeIcon: const Icon(Icons.access_time_filled),
          label: AppStrings.get('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.menu_book_outlined),
          activeIcon: const Icon(Icons.menu_book),
          label: AppStrings.get('quran'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.explore_outlined),
          activeIcon: const Icon(Icons.explore),
          label: AppStrings.get('qibla'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_month_outlined),
          activeIcon: const Icon(Icons.calendar_month),
          label: AppStrings.get('calendar'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: AppStrings.get('settings'),
        ),
      ],
    );
  }
}
