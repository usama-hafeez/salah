import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart' as q;
import '../../../core/services/quran_service.dart';
import '../services/bookmark_service.dart';
import '../models/bookmark_model.dart';

class RecitationBottomSheet extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final dynamic theme;

  const RecitationBottomSheet({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    required this.theme,
  });

  @override
  State<RecitationBottomSheet> createState() => _RecitationBottomSheetState();
}

class _RecitationBottomSheetState extends State<RecitationBottomSheet> {
  bool _isBookmarked = false;
  bool _loadingBookmark = true;
  String? _englishTranslation;
  String? _urduTranslation;
  bool _showTranslation = false;
  bool _loadingTranslation = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final result = await BookmarkService.isVerseBookmarked(
      widget.surahNumber,
      widget.verseNumber,
    );
    if (mounted) setState(() { _isBookmarked = result; _loadingBookmark = false; });
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await BookmarkService.remove(widget.surahNumber, widget.verseNumber);
    } else {
      await BookmarkService.add(RecitationBookmark(
        surahNumber: widget.surahNumber,
        verseNumber: widget.verseNumber,
        pageNumber: widget.pageNumber,
        timestamp: DateTime.now(),
      ));
    }
    if (!mounted) return;
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_isBookmarked ? 'Bookmark added' : 'Bookmark removed'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: widget.theme.surface,
    ));
  }

  Future<void> _loadTranslation() async {
    setState(() => _loadingTranslation = true);
    try {
      final verse = await QuranService.getSingleVerse(
        widget.surahNumber,
        widget.verseNumber,
      );
      if (mounted) {
        setState(() {
          _englishTranslation = verse?.textEnglish;
          _urduTranslation = verse?.textUrdu;
          _showTranslation = true;
          _loadingTranslation = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingTranslation = false);
    }
  }

  void _copyAyah() {
    final arabicText = q.getVerse(widget.surahNumber, widget.verseNumber,
        verseEndSymbol: false);
    final buffer = StringBuffer(arabicText);
    if (_englishTranslation != null) {
      buffer.write('\n\n$_englishTranslation');
    }
    buffer.write(
        '\n\n— Quran ${widget.surahNumber}:${widget.verseNumber}');
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Copied to clipboard'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: widget.theme.surface,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final surahName = q.getSurahName(widget.surahNumber);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: theme.textSecondary.withAlpha(80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Reference header
          Text(
            '$surahName  •  Ayah ${widget.verseNumber}',
            style: TextStyle(
              fontFamily: 'Hafs',
              color: theme.accent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 4),
          Text(
            'Page ${widget.pageNumber}',
            style: TextStyle(color: theme.textSecondary, fontSize: 12),
          ),

          Divider(color: theme.background, height: 24),

          // Translation panel (shown when user taps View Translation)
          if (_showTranslation) ...[
            _TranslationPanel(
              englishTranslation: _englishTranslation,
              urduTranslation: _urduTranslation,
              theme: theme,
            ),
            Divider(color: theme.background, height: 24),
          ],

          // Action tiles
          _OptionTile(
            icon: _isBookmarked
                ? Icons.bookmark_remove_outlined
                : Icons.bookmark_add_outlined,
            label: _loadingBookmark
                ? 'Loading…'
                : (_isBookmarked ? 'Remove Bookmark' : 'Bookmark this Ayah'),
            iconColor: theme.accent,
            theme: theme,
            onTap: _loadingBookmark ? null : _toggleBookmark,
          ),
          _OptionTile(
            icon: Icons.copy_outlined,
            label: 'Copy Ayah Text',
            iconColor: theme.textPrimary,
            theme: theme,
            onTap: _copyAyah,
          ),
          if (!_showTranslation)
            _OptionTile(
              icon: Icons.translate_outlined,
              label: _loadingTranslation ? 'Loading…' : 'View Translation',
              iconColor: theme.textPrimary,
              theme: theme,
              onTap: _loadingTranslation ? null : _loadTranslation,
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TranslationPanel extends StatelessWidget {
  final String? englishTranslation;
  final String? urduTranslation;
  final dynamic theme;

  const _TranslationPanel({
    required this.englishTranslation,
    required this.urduTranslation,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (englishTranslation == null && urduTranslation == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Translation not available',
          style: TextStyle(color: theme.textSecondary, fontSize: 13),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (englishTranslation != null)
          Text(
            englishTranslation!,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 14,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        if (urduTranslation != null) ...[
          const SizedBox(height: 10),
          Text(
            urduTranslation!,
            style: TextStyle(
              fontFamily: 'NotoNastaliq',
              color: theme.textSecondary,
              fontSize: 15,
              height: 1.8,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final dynamic theme;
  final VoidCallback? onTap;

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
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        label,
        style: TextStyle(color: theme.textPrimary, fontSize: 15),
      ),
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}
