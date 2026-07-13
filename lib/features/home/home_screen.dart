import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_assets.dart';
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
import '../settings/notification_settings_screen.dart';
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
          if (!provider.loading && provider.usingApproximateLocation)
            _ApproxLocationBanner(theme: theme),
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

class _ApproxLocationBanner extends StatelessWidget {
  final dynamic theme;
  const _ApproxLocationBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.accent.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off_outlined, size: 16, color: theme.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Using approximate location. Enable location for accurate times.',
              style: TextStyle(color: theme.textSecondary, fontSize: 12),
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                AppAssets.splashLogo,
                height: 36,
                width: 36,
                colorFilter: ColorFilter.mode(t.accent, BlendMode.srcIn),
              ),
              const SizedBox(width: 10),
              Text(
                'Salah',
                style: TextStyle(
                  color: t.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.location_on_outlined, color: t.accent, size: 32),
                tooltip: 'Location',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () {
                  context.read<PrayerProvider>().loadPrayerTimes();
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: t.accent.withAlpha(220), size: 32),
                tooltip: 'Notifications',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen()),
                ),
              ),
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
