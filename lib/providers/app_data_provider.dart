import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/earthquake_model.dart';
import '../utils/helper_functions.dart';

class AppDataProvider with ChangeNotifier {
  final Uri _baseUrl =
      Uri.parse('https://earthquake.usgs.gov/fdsnws/event/1/query');
  final Map<String, dynamic> _queryParams = {};

  final double _maxRadiusKm = 300.0; // okruh pri filtrovaní podľa polohy
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _startTime = '';
  String _endTime = '';
  String _orderBy = 'time'; // predvolené triedenie: najnovšie prvé
  double _minMagnitude = 4.0;
  String? _currentCity;
  bool _shouldUseLocation = false;
  bool _isLoading = false;
  String? _errorMessage;
  EarthquakeModel? _earthquakeModel;

  // ------------------------- GETTERY -------------------------

  double get maxRadiusKm => _maxRadiusKm;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get startTime => _startTime;
  String get endTime => _endTime;
  String get orderBy => _orderBy;
  double get minMagnitude => _minMagnitude;
  String? get currentCity => _currentCity;
  bool get shouldUseLocation => _shouldUseLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  EarthquakeModel? get earthquakeModel => _earthquakeModel;

  bool get hasDataLoaded => _earthquakeModel != null;

  List<Features> get earthquakes => _earthquakeModel?.features ?? [];

  // Začiatočný dátum nesmie byť neskôr ako koncový
  bool get isDateRangeValid =>
      !DateTime.parse(_startTime).isAfter(DateTime.parse(_endTime));

  // ------------------------- INICIALIZÁCIA -------------------------

  void init() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    _startTime = getFormattedDateTime(yesterday.millisecondsSinceEpoch);
    _endTime = getFormattedDateTime(now.millisecondsSinceEpoch);
    _setQueryParams();
    getEarthquakeData();
  }

  void _setQueryParams() {
    // API berie endtime ako polnoc daného dňa, preto posielame nasledujúci
    // deň – inak by sa vynechali zemetrasenia z posledného zvoleného dňa.
    final endExclusive = DateTime.parse(_endTime).add(const Duration(days: 1));

    _queryParams
      ..clear()
      ..['format'] = 'geojson'
      ..['starttime'] = _startTime
      ..['endtime'] = getFormattedDateTime(endExclusive.millisecondsSinceEpoch)
      ..['minmagnitude'] = '$_minMagnitude'
      ..['orderby'] = _orderBy
      ..['limit'] = '500';

    // Filtrovanie podľa polohy len keď je zapnuté
    if (_shouldUseLocation) {
      _queryParams['latitude'] = '$_latitude';
      _queryParams['longitude'] = '$_longitude';
      _queryParams['maxradiuskm'] = '$_maxRadiusKm';
    }
  }

  // ------------------------- NAČÍTANIE DÁT -------------------------

  Future<void> getEarthquakeData() async {
    final uri = Uri.https(_baseUrl.authority, _baseUrl.path, _queryParams);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    EasyLoading.show(status: 'Loading...');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _earthquakeModel = EarthquakeModel.fromJson(json);
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (error) {
      _errorMessage = 'Could not load data. Check your connection.';
      debugPrint(error.toString());
    } finally {
      _isLoading = false;
      EasyLoading.dismiss();
      notifyListeners();
    }
  }

  // ------------------------- TRIEDENIE A FILTRE -------------------------

  void setOrder(String value) {
    if (value == _orderBy) return;
    _orderBy = value;
    _setQueryParams();
    notifyListeners();
    getEarthquakeData(); // nové poradie sa načíta okamžite
  }

  void setMinMagnitude(double value) {
    if (value == _minMagnitude) return;
    _minMagnitude = value;
    _setQueryParams();
    notifyListeners();
    getEarthquakeData();
  }

  // Dátumy sa len uložia – načítanie spustí tlačidlo „Update Time Changes“
  void setStartTime(String date) {
    _startTime = date;
    _setQueryParams();
    notifyListeners();
  }

  void setEndTime(String date) {
    _endTime = date;
    _setQueryParams();
    notifyListeners();
  }

  // Zapnutie/vypnutie filtra podľa polohy.
  // Vráti chybovú správu, ak sa polohu nepodarilo získať.
  Future<String?> setLocation(bool value) async {
    if (value) {
      final error = await _determinePosition();
      if (error != null) {
        _shouldUseLocation = false;
        notifyListeners();
        return error;
      }
    } else {
      _currentCity = null;
    }
    _shouldUseLocation = value;
    _setQueryParams();
    notifyListeners();
    await getEarthquakeData();
    return null;
  }

  Future<String?> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'Location services are disabled.';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return 'Location permission was denied.';
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _latitude = position.latitude;
      _longitude = position.longitude;
      await _getCurrentCity();
      return null;
    } catch (error) {
      debugPrint(error.toString());
      return 'Could not get your location.';
    }
  }

  Future<void> _getCurrentCity() async {
    try {
      // Na webe geocoding nie je podporovaný – vyhodí chybu a mesto ostane null
      final placemarks =
          await Geocoding().placemarkFromCoordinates(_latitude, _longitude);
      if (placemarks.isNotEmpty) {
        _currentCity = placemarks.first.locality;
      }
    } catch (error) {
      debugPrint(error.toString());
      _currentCity = null;
    }
  }

  // ------------------------- POMOCNÉ -------------------------

  Color getAlertColor(String color) {
    return switch (color) {
      'green' => Colors.green,
      'yellow' => Colors.yellow,
      'orange' => Colors.orange,
      _ => Colors.red,
    };
  }
}
