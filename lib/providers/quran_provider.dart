import 'package:flutter/material.dart';

class QuranProvider extends ChangeNotifier {
  int? _currentSurahId;
  int _currentAyah = 1;

  int? get currentSurahId => _currentSurahId;
  int get currentAyah => _currentAyah;

  void openSurah(int surahId) {
    _currentSurahId = surahId;
    _currentAyah = 1;
    notifyListeners();
  }

  void setAyah(int ayah) {
    _currentAyah = ayah;
    notifyListeners();
  }
}
