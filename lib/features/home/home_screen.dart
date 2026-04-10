import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/services/storage_service.dart';
import 'widgets/date_header_widget.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/prayer_list_tile.dart';
import '../../shared/ad_banner_widget.dart';
import '../../shared/bottom_nav_bar.dart';
import '../../shared/loading_widget.dart';
import '../quran/quran_home_screen.dart';
import '../qibla/qibla_screen.dart';
import '../calendar/hijri_calendar_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  static const _screens = [
    _PrayerTimesTab(),
    QuranHomeScreen(),
    QiblaScreen(),
    HijriCalendarScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().loadPrayerTimes();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<PrayerProvider>().loadPrayerTimes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    return Scaffold(
      backgroundColor: theme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _PrayerTimesTab extends StatelessWidget {
  const _PrayerTimesTab();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    final provider = context.watch<PrayerProvider>();
    final isPro = StorageService.isPro;

    return SafeArea(
      child: Column(
        children: [
          _AppHeader(theme: theme),
          Expanded(
            child: provider.loading
                ? const LoadingWidget()
                : provider.error != null && provider.prayerTimes == null
                    ? _ErrorView(
                        onRetry: () =>
                            context.read<PrayerProvider>().loadPrayerTimes(),
                      )
                    : const _PrayerContent(),
          ),
          if (!isPro) const AdBannerWidget(),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  final dynamic theme;
  const _AppHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeProvider>().current;
    return Container(
      color: t.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SALAH',
            style: TextStyle(
              color: t.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: t.accent, size: 18),
              const SizedBox(width: 4),
              Icon(Icons.notifications_outlined, color: t.textPrimary.withAlpha(200), size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerContent extends StatelessWidget {
  const _PrayerContent();

  @override
  Widget build(BuildContext context) {
    final prayers = context.watch<PrayerProvider>().prayerModels;
    return ListView(
      children: [
        const DateHeaderWidget(),
        const NextPrayerCard(),
        const SizedBox(height: 4),
        ...prayers.map((p) => PrayerListTile(prayer: p)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined,
                color: theme.textSecondary, size: 52),
            const SizedBox(height: 16),
            Text(
              'Location unavailable',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Using last saved location for prayer times.',
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: Colors.black,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
