import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocationService {
  /// Asks for permission if needed and returns the current GPS position.
  Future<Position> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException('Lokalizačné služby sú vypnuté.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Prístup k polohe bol zamietnutý.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Prístup k polohe je trvalo zamietnutý. Povoľte ho v nastaveniach.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }
}
