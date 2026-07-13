import 'package:geolocator/geolocator.dart';
import 'storage_service.dart';

class LocationService {
  /// True when the last [getCurrentPosition] call returned the saved/default
  /// location instead of a live GPS fix (permission denied, service off, or
  /// timeout). The UI can use this to warn that prayer times are approximate.
  static bool isUsingFallback = false;

  /// Returns current GPS position.
  /// Falls back to last saved location if permission denied or unavailable.
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _fallback();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _fallback();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return _fallback();
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      await StorageService.setLastLocation(pos.latitude, pos.longitude);
      isUsingFallback = false;
      return pos;
    } catch (_) {
      return _fallback();
    }
  }

  static Position _fallback() {
    isUsingFallback = true;
    return Position(
      latitude: StorageService.lastLat,
      longitude: StorageService.lastLng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}
