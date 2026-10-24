import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/providers/places_provider.dart';
import 'package:flutter_application_1/services/api_service.dart';

void main() {
  testWidgets('app does not overflow when the window is almost zero wide', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final client = MockClient(
      (request) async => http.Response(
        jsonEncode({
          'data': [
            {
              'id': 1,
              'name': 'Bratislavský hrad',
              'description': '',
              'category': 'culture',
              'rating': 5,
              'latitude': null,
              'longitude': null,
              'photo': null,
              'is_favorite': true,
              'visited_at': '2026-05-14',
              'created_at': '2026-05-14 10:00:00',
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );
    final provider = PlacesProvider(api: ApiService(client: client));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: provider, child: const PlacesApp()),
    );
    await provider.loadPlaces();
    await tester.pump();

    expect(provider.allPlaces, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
