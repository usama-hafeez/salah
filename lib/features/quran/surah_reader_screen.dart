import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/ad_service.dart';
import '../../models/surah_model.dart';
import '../../models/verse_model.dart';
import '../../shared/loading_widget.dart';
import '../quran_recitation/screens/recitation_screen.dart';

class SurahReaderScreen extends StatefulWidget {
  final SurahModel surah;
  const SurahReaderScreen({super.key, required this.surah});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  // Show Basmala before verse 1 for all surahs except Al-Fatiha (1) and At-Tawbah (9)
  bool get _showBasmala =>
      widget.surah.id != 1 && widget.surah.id != 9;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    final provider = context.watch<QuranProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primary,
        foregroundColor: theme.textPrimary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.surah.nameEnglish,
              style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              '${widget.surah.ayahCount} verses  •  ${widget.surah.revelation ?? "Meccan"}',
              style: TextStyle(color: theme.textSecondary, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_book_outlined, color: theme.accent, size: 22),
            tooltip: 'Recite Mushaf',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecitationScreen(
                  surahNumber: widget.surah.id,
                  startAyah: 1,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              widget.surah.nameArabic,
              style: TextStyle(
                fontFamily: 'Hafs',
                color: theme.accent,
                fontSize: 20,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
      body: provider.loadingAyahs
          ? const LoadingWidget()
          : provider.ayahs.isEmpty
              ? _EmptyView(theme: theme)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount:
                      provider.ayahs.length + (_showBasmala ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_showBasmala && index == 0) {
                      return _BasmalaHeader(theme: theme);
                    }
                    final ayah =
                        provider.ayahs[_showBasmala ? index - 1 : index];
                    return _AyahCard(
                      ayah: ayah,
                      surahId: widget.surah.id,
                      theme: theme,
                    );
                  },
                ),
    );
  }
}

// ── Basmala ──────────────────────────────────────────────────────────────────

class _BasmalaHeader extends StatelessWidget {
  final dynamic theme;
  const _BasmalaHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.background, width: 2),
        ),
      ),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        style: TextStyle(
          fontFamily: 'Hafs',
          color: theme.accent,
          fontSize: 26,
          height: 1.8,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

// ── Ayah card ─────────────────────────────────────────────────────────────────

class _AyahCard extends StatefulWidget {
  final VerseModel ayah;
  final int surahId;
  final dynamic theme;

  const _AyahCard({
    required this.ayah,
    required this.surahId,
    required this.theme,
  });

  @override
  State<_AyahCard> createState() => _AyahCardState();
}

class _AyahCardState extends State<_AyahCard> {
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final result = await context
        .read<QuranProvider>()
        .isBookmarked(widget.surahId, widget.ayah.ayahNumber);
    if (mounted) setState(() => _bookmarked = result);
  }

  Future<void> _toggleBookmark() async {
    final provider = context.read<QuranProvider>();
    final wasBookmarked = _bookmarked;
    if (_bookmarked) {
      await provider.removeBookmark(widget.surahId, widget.ayah.ayahNumber);
    } else {
      await provider.addBookmark(widget.surahId, widget.ayah.ayahNumber);
    }
    if (!mounted) return;
    setState(() => _bookmarked = !_bookmarked);
    // Show interstitial after adding a bookmark (not on removal) — max 1 per 10 min
    if (!wasBookmarked) AdService.showInterstitial();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_bookmarked ? 'Bookmark added' : 'Bookmark removed'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.theme.surface,
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AyahOptionsSheet(
        ayah: widget.ayah,
        surahId: widget.surahId,
        isBookmarked: _bookmarked,
        theme: widget.theme,
        onBookmark: () async {
          Navigator.pop(context);
          await _toggleBookmark();
        },
        onCopy: () {
          Navigator.pop(context);
          _copyToClipboard();
        },
        onShare: () {
          Navigator.pop(context);
          _shareAyah();
        },
      ),
    );
  }

  void _copyToClipboard() {
    final buf = StringBuffer(widget.ayah.textArabic);
    if (widget.ayah.textEnglish != null) {
      buf.write('\n\n${widget.ayah.textEnglish}');
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.theme.surface,
      ),
    );
  }

  void _shareAyah() {
    final buf = StringBuffer(widget.ayah.textArabic);
    if (widget.ayah.textEnglish != null) {
      buf.write('\n\n${widget.ayah.textEnglish}');
    }
    buf.write('\n\n— Quran ${widget.surahId}:${widget.ayah.ayahNumber}');
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied — ready to share'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.theme.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return GestureDetector(
      onLongPress: _showOptions,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.surface.withAlpha(180), width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Number row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AyahNumberBadge(
                    number: widget.ayah.ayahNumber, theme: theme),
                GestureDetector(
                  onTap: _toggleBookmark,
                  child: Icon(
                    _bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_outlined,
                    color:
                        _bookmarked ? theme.accent : theme.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Arabic — RTL Hafs 26sp
            Text(
              widget.ayah.textArabic,
              style: AppTextStyles.arabicVerse(theme.textPrimary),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            // English translation
            if (widget.ayah.textEnglish != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.ayah.textEnglish!,
                style: AppTextStyles.englishTranslation(theme.textSecondary),
              ),
            ],
            // Urdu translation
            if (widget.ayah.textUrdu != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.ayah.textUrdu!,
                style: AppTextStyles.urduTranslation(theme.textSecondary),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Ayah number badge ─────────────────────────────────────────────────────────

class _AyahNumberBadge extends StatelessWidget {
  final int number;
  final dynamic theme;

  const _AyahNumberBadge({required this.number, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.accent.withAlpha(30),
        shape: BoxShape.circle,
        border: Border.all(color: theme.accent.withAlpha(80), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: TextStyle(
          color: theme.accent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _AyahOptionsSheet extends StatelessWidget {
  final VerseModel ayah;
  final int surahId;
  final bool isBookmarked;
  final dynamic theme;
  final VoidCallback onBookmark;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _AyahOptionsSheet({
    required this.ayah,
    required this.surahId,
    required this.isBookmarked,
    required this.theme,
    required this.onBookmark,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: theme.textSecondary.withAlpha(80),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            'Surah $surahId  :  Ayah ${ayah.ayahNumber}',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Divider(color: theme.background, height: 1),
        _OptionTile(
          icon: isBookmarked
              ? Icons.bookmark_remove_outlined
              : Icons.bookmark_add_outlined,
          label: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
          iconColor: theme.accent,
          theme: theme,
          onTap: onBookmark,
        ),
        _OptionTile(
          icon: Icons.share_outlined,
          label: 'Share Verse',
          iconColor: theme.textPrimary,
          theme: theme,
          onTap: onShare,
        ),
        _OptionTile(
          icon: Icons.copy_outlined,
          label: 'Copy Text',
          iconColor: theme.textPrimary,
          theme: theme,
          onTap: onCopy,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final dynamic theme;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(label,
          style: TextStyle(color: theme.textPrimary, fontSize: 15)),
      onTap: onTap,
    );
  }
}

class _EmptyView extends StatelessWidget {
  final dynamic theme;
  const _EmptyView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No verses found.',
        style: TextStyle(color: theme.textSecondary, fontSize: 14),
      ),
    );
  }
}
