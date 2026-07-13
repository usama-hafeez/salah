import 'package:flutter/material.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart' as q;
import '../models/bookmark_model.dart';

class BookmarkTile extends StatelessWidget {
  final RecitationBookmark bookmark;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final dynamic theme;

  const BookmarkTile({
    super.key,
    required this.bookmark,
    required this.onDelete,
    required this.onTap,
    required this.theme,
  });

  String get _surahName => q.getSurahName(bookmark.surahNumber);

  String get _arabicSnippet {
    try {
      return q.getVerse(bookmark.surahNumber, bookmark.verseNumber,
          verseEndSymbol: false);
    } catch (_) {
      return '';
    }
  }

  String get _formattedDate {
    final dt = bookmark.timestamp.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('rbm_${bookmark.surahNumber}_${bookmark.verseNumber}'),
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
                child: Icon(Icons.bookmark_rounded, color: theme.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _surahName,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• Ayah ${bookmark.verseNumber}',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (_arabicSnippet.isNotEmpty)
                      Text(
                        _arabicSnippet,
                        style: TextStyle(
                          fontFamily: 'Hafs',
                          color: theme.textPrimary.withAlpha(180),
                          fontSize: 14,
                          height: 1.6,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      'Page ${bookmark.pageNumber}  •  $_formattedDate',
                      style: TextStyle(color: theme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: theme.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
