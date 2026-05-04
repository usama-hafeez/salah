import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_model.dart';

class BookmarkService {
  static const _key = 'recitation_bookmarks_v1';

  static Future<List<RecitationBookmark>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final bookmarks = raw
        .map((s) => RecitationBookmark.fromJsonString(s))
        .toList();
    bookmarks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return bookmarks;
  }

  static Future<void> add(RecitationBookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    // Replace any existing bookmark on the same page
    all.removeWhere((b) => b.pageNumber == bookmark.pageNumber);
    all.insert(0, bookmark);
    await prefs.setStringList(
      _key,
      all.map((b) => b.toJsonString()).toList(),
    );
  }

  static Future<void> removeByPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.removeWhere((b) => b.pageNumber == pageNumber);
    await prefs.setStringList(
      _key,
      all.map((b) => b.toJsonString()).toList(),
    );
  }

  static Future<void> remove(int surahNumber, int verseNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.removeWhere(
      (b) => b.surahNumber == surahNumber && b.verseNumber == verseNumber,
    );
    await prefs.setStringList(
      _key,
      all.map((b) => b.toJsonString()).toList(),
    );
  }

  static Future<bool> isPageBookmarked(int pageNumber) async {
    final all = await getAll();
    return all.any((b) => b.pageNumber == pageNumber);
  }

  static Future<bool> isVerseBookmarked(int surahNumber, int verseNumber) async {
    final all = await getAll();
    return all.any(
      (b) => b.surahNumber == surahNumber && b.verseNumber == verseNumber,
    );
  }
}
