import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/place.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Talks to the PHP backend in the `backend/` folder (served by WAMP).
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 15);

  /// The Android emulator reaches the host machine through 10.0.2.2.
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/flutter-app/backend';
    }
    return 'http://localhost/flutter-app/backend';
  }

  static String photoUrl(String photo) => '$baseUrl/$photo';

  Uri _uri(String endpoint, {int? id}) {
    return Uri.parse('$baseUrl/api/places/$endpoint.php')
        .replace(queryParameters: id == null ? null : {'id': '$id'});
  }

  static const _jsonHeaders = {'Content-Type': 'application/json'};

  Future<List<Place>> fetchPlaces() async {
    final data = await _send(() => _client.get(_uri('list'))) as List<dynamic>;
    return data
        .map((json) => Place.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Place> createPlace(Place place) async {
    final data = await _send(
      () => _client.post(
        _uri('create'),
        headers: _jsonHeaders,
        body: jsonEncode(place.toJson()),
      ),
    );
    return Place.fromJson(data as Map<String, dynamic>);
  }

  Future<Place> updatePlace(Place place) async {
    final data = await _send(
      () => _client.put(
        _uri('update', id: place.id),
        headers: _jsonHeaders,
        body: jsonEncode(place.toJson()),
      ),
    );
    return Place.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deletePlace(int id) async {
    await _send(() => _client.delete(_uri('delete', id: id)));
  }

  Future<Place> toggleFavorite(int id) async {
    final data = await _send(
      () => _client.post(_uri('toggle_favorite', id: id)),
    );
    return Place.fromJson(data as Map<String, dynamic>);
  }

  /// Uploads an image and returns its path to be stored in [Place.photo].
  Future<String> uploadPhoto(Uint8List bytes, String filename) async {
    final data = await _send(() async {
      final request = http.MultipartRequest('POST', _uri('upload_photo'))
        ..files.add(
          http.MultipartFile.fromBytes('photo', bytes, filename: filename),
        );
      return http.Response.fromStream(await _client.send(request));
    });
    return (data as Map<String, dynamic>)['photo'] as String;
  }

  /// Runs the request and unwraps the `{"data": ...}` / `{"error": ...}` envelope.
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('Server neodpovedá. Skúste to znova.');
    } on http.ClientException {
      throw const ApiException(
        'Nepodarilo sa pripojiť k serveru. Beží WAMP server?',
      );
    }

    final Object? body;
    try {
      body = jsonDecode(response.body);
    } on FormatException {
      throw ApiException('Neplatná odpoveď servera (${response.statusCode}).');
    }

    if (body is! Map<String, dynamic>) {
      throw const ApiException('Neplatná odpoveď servera.');
    }
    if (response.statusCode >= 400) {
      throw ApiException(
        body['error'] as String? ?? 'Chyba servera (${response.statusCode}).',
      );
    }
    return body['data'];
  }
}
