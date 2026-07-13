import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/surah_model.dart';
import '../../shared/loading_widget.dart';
import 'surah_reader_screen.dart';

class QuranBookmarksScreen extends StatefulWidget {
  const QuranBookmarksScreen({super.key});

  @override
  State<QuranBookmarksScreen> createState() => _QuranBookmarksScreenState();
}

class _QuranBookmarksScreenState extends State<QuranBookmarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadBookmarks();
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
          'Bookmarks',
          style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      body: provider.bookmarks.isEmpty
          ? _EmptyState(theme: theme)
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: provider.bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = provider.bookmarks[index];
                return _BookmarkTile(
                  bookmark: bookmark,
                  theme: theme,
                  onDelete: () async {
                    await provider.removeBookmark(
                      bookmark['surah_id'] as int,
                      bookmark['ayah_number'] as int,
                    );
                  },
                  onTap: () => _openSurah(
                    context,
                    provider,
                    bookmark['surah_id'] as int,
                    bookmark['ayah_number'] as int,
                  ),
                );
              },
            ),
    );
  }

  void _openSurah(
    BuildContext context,
    QuranProvider provider,
    int surahId,
    int ayahNumber,
  ) {
    // Find surah from loaded list or create a minimal model
    SurahModel? surah;
    if (provider.surahs.isNotEmpty) {
      try {
        surah = provider.surahs.firstWhere((s) => s.id == surahId);
      } catch (_) {}
    }

    surah ??= SurahModel(
      id: surahId,
      nameArabic: '',
      nameEnglish: 'Surah $surahId',
      ayahCount: 0,
    );

    provider.openSurah(surah);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurahReaderScreen(surah: surah!)),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final Map<String, dynamic> bookmark;
  final dynamic theme;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _BookmarkTile({
    required this.bookmark,
    required this.theme,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surahId = bookmark['surah_id'] as int;
    final ayahNumber = bookmark['ayah_number'] as int;
    final createdAt = bookmark['created_at'] as String? ?? '';

    return Dismissible(
      key: Key('bookmark_${surahId}_$ayahNumber'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade800,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.surface, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.bookmark_rounded,
                    color: theme.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Surah $surahId  •  Verse $ayahNumber',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                          color: theme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final dynamic theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border_outlined,
                color: theme.textSecondary, size: 52),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Long-press any verse in the Quran reader\nto add a bookmark.',
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
