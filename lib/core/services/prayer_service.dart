import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'storage_service.dart';

class PrayerService {
  /// Calculate today's prayer times based on position and saved settings.
  static PrayerTimes getPrayerTimes(Position position) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = _getCalculationParameters();
    final dateComponents = DateComponents.from(DateTime.now());
    return PrayerTimes(coordinates, dateComponents, params);
  }

  /// Get prayer times for a specific date.
  static PrayerTimes getPrayerTimesForDate(Position position, DateTime date) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = _getCalculationParameters();
    final dateComponents = DateComponents.from(date);
    return PrayerTimes(coordinates, dateComponents, params);
  }

  static CalculationParameters _getCalculationParameters() {
    CalculationParameters params;
    switch (StorageService.calculationMethod) {
      case 'ISNA':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'MWL':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'Egypt':
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 'Tehran':
        params = CalculationMethod.tehran.getParameters();
        break;
      case 'Gulf':
        params = CalculationMethod.kuwait.getParameters();
        break;
      case 'Karachi':
      default:
        params = CalculationMethod.karachi.getParameters();
        break;
    }

    if (StorageService.madhab == 'Hanafi') {
      params.madhab = Madhab.hanafi;
    } else {
      params.madhab = Madhab.shafi;
    }

    return params;
  }

  /// Returns the name of the currently active or next prayer.
  static Prayer currentPrayer(PrayerTimes times) {
    return times.currentPrayer();
  }

  /// Returns DateTime for a specific prayer.
  static DateTime? timeForPrayer(PrayerTimes times, Prayer prayer) {
    return times.timeForPrayer(prayer);
  }

  /// Returns map of prayer name → DateTime for display (includes Sunrise).
  static Map<String, DateTime?> allPrayerTimes(PrayerTimes times) {
    return {
      'Fajr': times.fajr,
      'Sunrise': times.sunrise,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };
  }

  /// The 5 obligatory prayers only (excludes Sunrise).
  static Map<String, DateTime?> obligatoryPrayers(PrayerTimes times) {
    return {
      'Fajr': times.fajr,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };
  }
}
