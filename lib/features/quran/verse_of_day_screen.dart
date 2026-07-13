import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/verse_model.dart';
import '../../shared/loading_widget.dart';

class VerseOfDayScreen extends StatefulWidget {
  const VerseOfDayScreen({super.key});

  @override
  State<VerseOfDayScreen> createState() => _VerseOfDayScreenState();
}

class _VerseOfDayScreenState extends State<VerseOfDayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadVerseOfDay();
    });
  }

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
        title: Text(
          'Verse of the Day',
          style: TextStyle(
              color: theme.textPrimary, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (provider.verseOfDay != null)
            IconButton(
              icon: Icon(Icons.copy_outlined, color: theme.textPrimary),
              onPressed: () => _copyVerse(context, provider.verseOfDay!),
              tooltip: 'Copy verse',
            ),
        ],
      ),
      body: provider.loadingVod
          ? const LoadingWidget()
          : provider.verseOfDay == null
              ? _ErrorView(theme: theme)
              : _VerseContent(verse: provider.verseOfDay!, theme: theme),
    );
  }

  void _copyVerse(BuildContext context, VerseModel verse) {
    final buf = StringBuffer(verse.textArabic);
    if (verse.textEnglish != null) {
      buf.write('\n\n${verse.textEnglish}');
    }
    buf.write('\n\n— Quran ${verse.surahId}:${verse.ayahNumber}');
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _VerseContent extends StatelessWidget {
  final VerseModel verse;
  final dynamic theme;

  const _VerseContent({required this.verse, required this.theme});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final dateStr =
        '${months[today.month - 1]} ${today.day}, ${today.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date badge
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: theme.accent.withAlpha(60), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: theme.accent, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: theme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Arabic text
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: theme.accent.withAlpha(40), width: 1),
            ),
            child: Text(
              verse.textArabic,
              style: AppTextStyles.arabicVerse(theme.textPrimary),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 20),
          // English translation
          if (verse.textEnglish != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.surface.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Translation',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"${verse.textEnglish}"',
                    style: AppTextStyles.englishTranslation(theme.textPrimary)
                        .copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Urdu translation
          if (verse.textUrdu != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.surface.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ترجمہ',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    verse.textUrdu!,
                    style: AppTextStyles.urduTranslation(theme.textPrimary),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Reference
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.primary.withAlpha(60),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Surah ${verse.surahId}  :  Ayah ${verse.ayahNumber}',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (verse.juz != null)
                  Text(
                    'Juz ${verse.juz}',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final dynamic theme;
  const _ErrorView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined,
                color: theme.textSecondary, size: 52),
            const SizedBox(height: 16),
            Text(
              'Verse unavailable',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The Quran database has not been set up yet.\nSee scripts/build_quran_db.py for setup instructions.',
              style: TextStyle(
                  color: theme.textSecondary, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
