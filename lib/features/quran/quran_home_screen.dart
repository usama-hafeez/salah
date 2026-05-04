import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/surah_model.dart';
import '../../shared/premium_lock_widget.dart';
import '../../shared/loading_widget.dart';
import '../premium/paywall_screen.dart';
import 'surah_reader_screen.dart';
import 'quran_bookmarks_screen.dart';
import 'verse_of_day_screen.dart';
import '../quran_recitation/screens/recitation_screen.dart';

class QuranHomeScreen extends StatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  State<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends State<QuranHomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSurahs();
      context.read<QuranProvider>().loadVerseOfDay();
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return PremiumLockWidget(
      onUpgrade: _openPaywall,
      child: Scaffold(
        backgroundColor: theme.background,
        body: SafeArea(
          child: Column(
            children: [
              _QuranHeader(theme: theme),
              _SearchBar(controller: _searchController, theme: theme),
              Expanded(
                child: _QuranBody(searchQuery: _searchQuery),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuranHeader extends StatelessWidget {
  final dynamic theme;
  const _QuranHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'القرآن الكريم',
                style: TextStyle(
                  fontFamily: 'Hafs',
                  color: theme.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'The Holy Quran',
                style: TextStyle(
                  color: theme.textPrimary.withAlpha(180),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _HeaderIconButton(
                icon: Icons.bookmark_border_outlined,
                theme: theme,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QuranBookmarksScreen()),
                ),
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                icon: Icons.auto_awesome_outlined,
                theme: theme,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const VerseOfDayScreen()),
                ),
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                icon: Icons.menu_book_outlined,
                theme: theme,
                tooltip: 'Recite Mushaf',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecitationScreen(
                      surahNumber: 1,
                      startAyah: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final dynamic theme;
  final VoidCallback onTap;
  final String? tooltip;

  const _HeaderIconButton({
    required this.icon,
    required this.theme,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.accent, size: 22),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final dynamic theme;

  const _SearchBar({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: controller,
        style: TextStyle(color: theme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search surah name or number…',
          hintStyle: TextStyle(color: theme.textSecondary, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: theme.textSecondary, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: controller.clear,
                  child: Icon(Icons.close, color: theme.textSecondary, size: 18),
                )
              : null,
          filled: true,
          fillColor: Colors.black.withAlpha(60),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _QuranBody extends StatelessWidget {
  final String searchQuery;
  const _QuranBody({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranProvider>();
    final theme = context.watch<ThemeProvider>().current;

    if (provider.loadingSurahs) {
      return const LoadingWidget();
    }

    if (provider.error != null && provider.surahs.isEmpty) {
      return _ErrorView(
        error: provider.error!,
        onRetry: () => context.read<QuranProvider>().loadSurahs(),
      );
    }

    final surahs = provider.searchSurahs(searchQuery);

    return CustomScrollView(
      slivers: [
        if (searchQuery.isEmpty) ...[
          SliverToBoxAdapter(child: _VerseOfDayCard(theme: theme)),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                '114 Surahs',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _SurahTile(surah: surahs[index]),
            childCount: surahs.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _VerseOfDayCard extends StatelessWidget {
  final dynamic theme;
  const _VerseOfDayCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranProvider>();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VerseOfDayScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.primary, theme.secondary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withAlpha(100),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.accent, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Verse of the Day',
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right,
                    color: theme.textPrimary.withAlpha(120), size: 18),
              ],
            ),
            const SizedBox(height: 14),
            if (provider.loadingVod)
              SizedBox(
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: theme.accent, strokeWidth: 2),
                  ),
                ),
              )
            else if (provider.verseOfDay != null) ...[
              Text(
                provider.verseOfDay!.textArabic,
                style: TextStyle(
                  fontFamily: 'Hafs',
                  color: theme.textPrimary,
                  fontSize: 20,
                  height: 1.8,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (provider.verseOfDay!.textEnglish != null) ...[
                const SizedBox(height: 8),
                Text(
                  provider.verseOfDay!.textEnglish!,
                  style: TextStyle(
                    color: theme.textPrimary.withAlpha(180),
                    fontSize: 13,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ] else
              Text(
                'Tap to read the verse of the day',
                style: TextStyle(
                    color: theme.textSecondary, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final SurahModel surah;
  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return InkWell(
      onTap: () {
        context.read<QuranProvider>().openSurah(surah);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurahReaderScreen(surah: surah),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.surface, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Surah number badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                surah.id.toString(),
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameEnglish,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        surah.revelation ?? 'Meccan',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '  •  ${surah.ayahCount} verses',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arabic name
            Text(
              surah.nameArabic,
              style: TextStyle(
                fontFamily: 'Hafs',
                color: theme.accent,
                fontSize: 18,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined,
                color: theme.textSecondary, size: 52),
            const SizedBox(height: 16),
            Text(
              'Could not load Quran',
              style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure the quran.db file is placed in\nassets/db/ and run flutter pub get.',
              style: TextStyle(
                  color: theme.textSecondary, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: Colors.black87,
                shape: const StadiumBorder(),
              ),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
