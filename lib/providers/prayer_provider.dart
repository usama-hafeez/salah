import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/prayer_service.dart';
import '../core/services/location_service.dart';
import '../core/services/widget_service.dart';

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
    final nextTime = _prayerTimes!.timeForPrayer(next);
    if (nextTime == null) return null;
    return nextTime.difference(DateTime.now());
  }
}
