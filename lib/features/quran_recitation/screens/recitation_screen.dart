import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import '../../../providers/theme_provider.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/recitation_bottom_sheet.dart';
import '../widgets/recitation_settings_sheet.dart';
import 'bookmarks_screen.dart';

class RecitationScreen extends StatefulWidget {
  final int surahNumber;
  final int startAyah;

  const RecitationScreen({
    super.key,
    required this.surahNumber,
    required this.startAyah,
  });

  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  late final PageController _pageController;

  late int _currentPage;   // 1-based (1–604)
  late int _currentSurah;
  bool _isLoading = true;
  bool _isPageBookmarked = false;

  RecitationSettings _settings = const RecitationSettings();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _currentPage = getPageNumber(widget.surahNumber, widget.startAyah);
    _currentSurah = widget.surahNumber;

    // PageController is 0-indexed; Quran pages are 1–604.
    _pageController = PageController(initialPage: _currentPage - 1);

    _checkBookmarkState();

    // The qcf_quran_lite data loads synchronously — clear shimmer after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Returns the first surah number on the given Quran page using the package's
  /// built-in page data table — no manual mapping needed.
  int _surahForPage(int pageNumber) {
    try {
      final entries = getPageData(pageNumber);
      return (entries.first as Map)['surah'] as int;
    } catch (_) {
      return _currentSurah;
    }
  }

  // ── State helpers ────────────────────────────────────────────────────────────

  // onPageChanged from QuranPageView already delivers 1-based page numbers.
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _currentSurah = _surahForPage(page);
    });
    _checkBookmarkState();
  }

  Future<void> _checkBookmarkState() async {
    final bookmarked = await BookmarkService.isPageBookmarked(_currentPage);
    if (mounted) setState(() => _isPageBookmarked = bookmarked);
  }

  Future<void> _togglePageBookmark() async {
    if (_isPageBookmarked) {
      await BookmarkService.removeByPage(_currentPage);
    } else {
      await BookmarkService.add(RecitationBookmark(
        surahNumber: _currentSurah,
        verseNumber: 1,
        pageNumber: _currentPage,
        timestamp: DateTime.now(),
      ));
    }
    if (!mounted) return;
    setState(() => _isPageBookmarked = !_isPageBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_isPageBookmarked ? 'Page bookmarked' : 'Bookmark removed'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showVerseOptions(int surahNumber, int verseNumber) {
    final theme = context.read<ThemeProvider>().current;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RecitationBottomSheet(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        pageNumber: _currentPage,
        theme: theme,
      ),
    );
  }

  void _showSettings() {
    final theme = context.read<ThemeProvider>().current;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RecitationSettingsSheet(
        initial: _settings,
        theme: theme,
        onChanged: (s) => setState(() => _settings = s),
      ),
    );
  }

  void _openBookmarks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecitationBookmarksScreen()),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    final surahNameArabic = getSurahNameArabic(_currentSurah);
    final juzNumber = getCurrentJuzNumberForPage(_currentPage);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _RecitationAppBar(
        surahNameArabic: surahNameArabic,
        juzNumber: juzNumber,
        theme: theme,
        onClose: () => Navigator.pop(context),
        onBookmarks: _openBookmarks,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Loading shimmer ────────────────────────────────────────────────
          if (_isLoading) _LoadingSkeleton(theme: theme),

          // ── Mushaf page view ───────────────────────────────────────────────
          _MushaPageArea(
            pageController: _pageController,
            settings: _settings,
            isLoading: _isLoading,
            onPageChanged: _onPageChanged,
            onLongPress: _showVerseOptions,
          ),

          // ── Warm overlay (brightness) ──────────────────────────────────────
          if (_settings.warmth < 0.98)
            IgnorePointer(
              child: Container(
                color: const Color(0xFFD4A055)
                    .withOpacity((1.0 - _settings.warmth) * 0.35),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        currentPage: _currentPage,
        isBookmarked: _isPageBookmarked,
        theme: theme,
        onBookmarkTap: _togglePageBookmark,
        onSettingsTap: _showSettings,
      ),
    );
  }
}

// ── Mushaf page area ──────────────────────────────────────────────────────────

class _MushaPageArea extends StatelessWidget {
  final PageController pageController;
  final RecitationSettings settings;
  final bool isLoading;
  final void Function(int page) onPageChanged;
  final void Function(int surahNumber, int verseNumber) onLongPress;

  const _MushaPageArea({
    required this.pageController,
    required this.settings,
    required this.isLoading,
    required this.onPageChanged,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Widget pageView = MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(settings.largeFont ? 1.35 : 1.0),
      ),
      child: QuranPageView(
        pageController: pageController,
        pageBackgroundColor: Colors.white,
        // onPageChanged already provides 1-based Quran page numbers.
        onPageChanged: onPageChanged,
        // onLongPress delivers (surahNumber, verseNumber) directly as ints.
        onLongPress: onLongPress,
        highlights: const [],
      ),
    );

    // Night-mode: invert page colours via ColorFilter matrix.
    if (settings.nightMode) {
      pageView = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          -1,  0,  0, 0, 255,
           0, -1,  0, 0, 255,
           0,  0, -1, 0, 255,
           0,  0,  0, 1,   0,
        ]),
        child: pageView,
      );
    }

    return Opacity(
      opacity: isLoading ? 0.0 : 1.0,
      child: pageView,
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _RecitationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String surahNameArabic;
  final int juzNumber;
  final dynamic theme;
  final VoidCallback onClose;
  final VoidCallback onBookmarks;

  const _RecitationAppBar({
    required this.surahNameArabic,
    required this.juzNumber,
    required this.theme,
    required this.onClose,
    required this.onBookmarks,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: theme.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(Icons.close, color: theme.textPrimary),
        onPressed: onClose,
        tooltip: 'Close',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            surahNameArabic,
            style: TextStyle(
              fontFamily: 'Hafs',
              color: theme.accent,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
          Text(
            'Juz $juzNumber',
            style: TextStyle(color: theme.textSecondary, fontSize: 11),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.bookmark_border_outlined, color: theme.textPrimary),
          onPressed: onBookmarks,
          tooltip: 'Bookmarks',
        ),
      ],
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final bool isBookmarked;
  final dynamic theme;
  final VoidCallback onBookmarkTap;
  final VoidCallback onSettingsTap;

  const _BottomBar({
    required this.currentPage,
    required this.isBookmarked,
    required this.theme,
    required this.onBookmarkTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: theme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _BottomBarButton(
            icon: isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_outlined,
            color: isBookmarked ? theme.accent : theme.textSecondary,
            onTap: onBookmarkTap,
            tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark this page',
          ),
          Expanded(
            child: Center(
              child: Text(
                '$currentPage / 604',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          _BottomBarButton(
            icon: Icons.tune_outlined,
            color: theme.textSecondary,
            onTap: onSettingsTap,
            tooltip: 'Reading settings',
          ),
        ],
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _BottomBarButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatefulWidget {
  final dynamic theme;
  const _LoadingSkeleton({required this.theme});

  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 16; i++) ...[
              Container(
                height: 18,
                width: i % 5 == 4
                    ? MediaQuery.of(context).size.width * 0.4
                    : double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(_anim.value * 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
