import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/surah_model.dart';
import '../../models/verse_model.dart';

class QuranService {
  static Database? _db;
  static Database? _userDb;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'quran.db');

    final exists = await File(path).exists();
    if (!exists) {
      // Copy bundled DB from assets to writable location on first run
      final data = await rootBundle.load('assets/db/quran.db');
      final bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(path, readOnly: true);
  }

  static Future<Database> get _userDatabase async {
    if (_userDb != null) return _userDb!;
    final dir = await getApplicationDocumentsDirectory();
    _userDb = await openDatabase(
      join(dir.path, 'user_data.db'),
      version: 1,
      onCreate: (db, v) => db.execute(
        'CREATE TABLE bookmarks ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'surah_id INTEGER, '
        'ayah_number INTEGER, '
        'created_at TEXT'
        ')',
      ),
    );
    return _userDb!;
  }

  static Future<List<SurahModel>> getAllSurahs() async {
    final db = await database;
    final result = await db.query('surahs', orderBy: 'id ASC');
    return result.map((r) => SurahModel.fromMap(r)).toList();
  }

  static Future<List<VerseModel>> getAyahs(int surahId) async {
    final db = await database;
    final result = await db.query(
      'ayahs',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'ayah_number ASC',
    );
    return result.map((r) => VerseModel.fromMap(r)).toList();
  }

  static Future<VerseModel> getVerseOfDay() async {
    final db = await database;
    final dayOfYear = DateTime.now()
            .difference(DateTime(DateTime.now().year, 1, 1))
            .inDays +
        1;
    final result = await db.query(
      'daily_verses',
      where: 'day_of_year = ?',
      whereArgs: [dayOfYear],
    );
    if (result.isEmpty) {
      // Fallback to Al-Fatiha ayah 1
      final fallback = await db.query(
        'ayahs',
        where: 'surah_id = ? AND ayah_number = ?',
        whereArgs: [1, 1],
      );
      return VerseModel.fromMap(fallback.first);
    }
    final ref = result.first;
    final ayah = await db.query(
      'ayahs',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [ref['surah_id'], ref['ayah_number']],
    );
    return VerseModel.fromMap(ayah.first);
  }

  static Future<void> addBookmark(int surahId, int ayahNumber) async {
    final db = await _userDatabase;
    // Avoid duplicates
    final existing = await db.query(
      'bookmarks',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [surahId, ayahNumber],
    );
    if (existing.isNotEmpty) return;
    await db.insert('bookmarks', {
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> removeBookmark(int surahId, int ayahNumber) async {
    final db = await _userDatabase;
    await db.delete(
      'bookmarks',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [surahId, ayahNumber],
    );
  }

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await _userDatabase;
    return db.query('bookmarks', orderBy: 'created_at DESC');
  }

  static Future<bool> isBookmarked(int surahId, int ayahNumber) async {
    final db = await _userDatabase;
    final result = await db.query(
      'bookmarks',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [surahId, ayahNumber],
    );
    return result.isNotEmpty;
  }
}
