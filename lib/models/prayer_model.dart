import 'prayer_status.dart';

class PrayerModel {
  final String name;
  final DateTime time;
  final PrayerStatus status;
  final String iconAsset;

  const PrayerModel({
    required this.name,
    required this.time,
    required this.status,
    required this.iconAsset,
  });
}
