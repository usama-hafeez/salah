import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/bookmark_tile.dart';
import 'recitation_screen.dart';

class RecitationBookmarksScreen extends StatefulWidget {
  const RecitationBookmarksScreen({super.key});

  @override
  State<RecitationBookmarksScreen> createState() =>
      _RecitationBookmarksScreenState();
}

class _RecitationBookmarksScreenState
    extends State<RecitationBookmarksScreen> {
  List<RecitationBookmark> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await BookmarkService.getAll();
    if (mounted) setState(() { _bookmarks = list; _loading = false; });
  }

  Future<void> _delete(RecitationBookmark bm) async {
    await BookmarkService.removeByPage(bm.pageNumber);
    setState(() => _bookmarks.removeWhere((b) => b.pageNumber == bm.pageNumber));
  }

  void _open(RecitationBookmark bm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecitationScreen(
          surahNumber: bm.surahNumber,
          startAyah: bm.verseNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primary,
        foregroundColor: theme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recitation Bookmarks',
          style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.accent,
                strokeWidth: 2,
              ),
            )
          : _bookmarks.isEmpty
              ? _EmptyState(theme: theme)
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bm = _bookmarks[index];
                    return BookmarkTile(
                      bookmark: bm,
                      theme: theme,
                      onDelete: () => _delete(bm),
                      onTap: () => _open(bm),
                    );
                  },
                ),
    );
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
              'No recitation bookmarks',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Open the Mushaf and long-press any ayah\nor tap the bookmark icon on any page.',
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
