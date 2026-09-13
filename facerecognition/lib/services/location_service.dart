import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();

  // Demo event centre (Nilgiri College, Coimbatore approx.)
  static const double _eventLat = 11.0168;
  static const double _eventLon = 76.9558;
  static const double _radiusMeters = 50.0;

  /// Returns distance in metres from the event venue,
  /// or null if permission denied.
  Future<double?> distanceFromEvent() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) return null;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return Geolocator.distanceBetween(
        pos.latitude, pos.longitude, _eventLat, _eventLon);
    } catch (_) {
      return null; // fallback handled by UI
    }
  }

  bool isInsideZone(double distanceMeters) =>
      distanceMeters <= _radiusMeters;

  double get zoneRadius => _radiusMeters;
}
