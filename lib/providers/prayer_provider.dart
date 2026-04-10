import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/prayer_service.dart';
import '../core/services/location_service.dart';
import '../core/services/widget_service.dart';
import '../core/constants/app_assets.dart';
import '../models/prayer_model.dart';
import '../models/prayer_status.dart';

class PrayerProvider extends ChangeNotifier {
  PrayerTimes? _prayerTimes;
  Position? _position;
  bool _loading = true;
  String? _error;

  PrayerTimes? get prayerTimes => _prayerTimes;
  Position? get position => _position;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadPrayerTimes() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _position = await LocationService.getCurrentPosition();
      _prayerTimes = PrayerService.getPrayerTimes(_position!);
      await WidgetService.updateWidget();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Prayer? get nextPrayer => _prayerTimes?.nextPrayer();
  Prayer? get currentPrayer => _prayerTimes?.currentPrayer();

  Duration? get timeToNextPrayer {
    if (_prayerTimes == null) return null;
    final next = _prayerTimes!.nextPrayer();
    if (next == Prayer.none) return null;
    final nextTime = _prayerTimes!.timeForPrayer(next);
    if (nextTime == null) return null;
    return nextTime.difference(DateTime.now());
  }

  String get nextPrayerName {
    if (_prayerTimes == null) return '--';
    final next = _prayerTimes!.nextPrayer();
    if (next == Prayer.none) return '--';
    return _prayerEnumName(next);
  }

  DateTime? get nextPrayerTime {
    if (_prayerTimes == null) return null;
    final next = _prayerTimes!.nextPrayer();
    if (next == Prayer.none) return null;
    return _prayerTimes!.timeForPrayer(next);
  }

  /// Returns the list of 5 obligatory prayers with their status for display.
  List<PrayerModel> get prayerModels {
    if (_prayerTimes == null) return [];
    final now = DateTime.now();
    final next = _prayerTimes!.nextPrayer();

    final prayers = [
      _buildModel('Fajr', Prayer.fajr, AppAssets.fajrIcon, next, now),
      _buildModel('Dhuhr', Prayer.dhuhr, AppAssets.dhuhrIcon, next, now),
      _buildModel('Asr', Prayer.asr, AppAssets.asrIcon, next, now),
      _buildModel('Maghrib', Prayer.maghrib, AppAssets.maghribIcon, next, now),
      _buildModel('Isha', Prayer.isha, AppAssets.ishaIcon, next, now),
    ];
    return prayers.whereType<PrayerModel>().toList();
  }

  PrayerModel? _buildModel(
    String name,
    Prayer prayer,
    String iconAsset,
    Prayer nextPrayer,
    DateTime now,
  ) {
    final time = _prayerTimes!.timeForPrayer(prayer);
    if (time == null) return null;

    PrayerStatus status;
    if (prayer == nextPrayer) {
      status = PrayerStatus.next;
    } else if (time.isBefore(now)) {
      status = PrayerStatus.passed;
    } else {
      status = PrayerStatus.upcoming;
    }

    return PrayerModel(
      name: name,
      time: time,
      status: status,
      iconAsset: iconAsset,
    );
  }

  static String _prayerEnumName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return '--';
    }
  }
}
