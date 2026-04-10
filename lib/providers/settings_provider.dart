import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../core/services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  String get calculationMethod => StorageService.calculationMethod;
  String get madhab => StorageService.madhab;
  String get language => StorageService.language;
  String get azaanSound => StorageService.azaanSound;

  Future<void> setCalculationMethod(String v) async {
    await StorageService.setCalculationMethod(v);
    await NotificationService.scheduleAllNotifications();
    notifyListeners();
  }

  Future<void> setMadhab(String v) async {
    await StorageService.setMadhab(v);
    await NotificationService.scheduleAllNotifications();
    notifyListeners();
  }

  Future<void> setLanguage(String v) async {
    await StorageService.setLanguage(v);
    notifyListeners();
  }

  Future<void> setAzaanSound(String v) async {
    await StorageService.setAzaanSound(v);
    await NotificationService.scheduleAllNotifications();
    notifyListeners();
  }
}
