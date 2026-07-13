import 'package:flutter/material.dart';
import '../core/services/quran_service.dart';
import '../models/surah_model.dart';
import '../models/verse_model.dart';

class QuranProvider extends ChangeNotifier {
  List<SurahModel> _surahs = [];
  List<VerseModel> _ayahs = [];
  List<Map<String, dynamic>> _bookmarks = [];
  VerseModel? _verseOfDay;
  SurahModel? _currentSurah;
  bool _loadingSurahs = false;
  bool _loadingAyahs = false;
  bool _loadingVod = false;
  String? _error;

  List<SurahModel> get surahs => _surahs;
  List<VerseModel> get ayahs => _ayahs;
  List<Map<String, dynamic>> get bookmarks => _bookmarks;
  VerseModel? get verseOfDay => _verseOfDay;
  SurahModel? get currentSurah => _currentSurah;
  bool get loadingSurahs => _loadingSurahs;
  bool get loadingAyahs => _loadingAyahs;
  bool get loadingVod => _loadingVod;
  String? get error => _error;

  List<SurahModel> searchSurahs(String query) {
    if (query.trim().isEmpty) return _surahs;
    final q = query.toLowerCase();
    return _surahs.where((s) {
      return s.nameEnglish.toLowerCase().contains(q) ||
          s.nameArabic.contains(query) ||
          s.id.toString() == q.trim();
    }).toList();
  }

  Future<void> loadSurahs() async {
    if (_surahs.isNotEmpty) return;
    _loadingSurahs = true;
    _error = null;
    notifyListeners();
    try {
      _surahs = await QuranService.getAllSurahs();
    } catch (e) {
      _error = e.toString();
    }
    _loadingSurahs = false;
    notifyListeners();
  }

  Future<void> openSurah(SurahModel surah) async {
    _currentSurah = surah;
    _ayahs = []; // clear previous surah's verses so they can't flash through
    _loadingAyahs = true;
    _error = null;
    notifyListeners();
    try {
      _ayahs = await QuranService.getAyahs(surah.id);
    } catch (e) {
      _error = e.toString();
    }
    _loadingAyahs = false;
    notifyListeners();
  }

  Future<void> loadVerseOfDay() async {
    if (_verseOfDay != null) return;
    _loadingVod = true;
    notifyListeners();
    try {
      _verseOfDay = await QuranService.getVerseOfDay();
    } catch (e) {
      _error = e.toString();
    }
    _loadingVod = false;
    notifyListeners();
  }

  Future<void> loadBookmarks() async {
    try {
      _bookmarks = await QuranService.getBookmarks();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addBookmark(int surahId, int ayahNumber) async {
    await QuranService.addBookmark(surahId, ayahNumber);
    await loadBookmarks();
  }

  Future<void> removeBookmark(int surahId, int ayahNumber) async {
    await QuranService.removeBookmark(surahId, ayahNumber);
    await loadBookmarks();
  }

  Future<bool> isBookmarked(int surahId, int ayahNumber) =>
      QuranService.isBookmarked(surahId, ayahNumber);
}
