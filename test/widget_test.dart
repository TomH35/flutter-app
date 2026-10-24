import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/place.dart';
import 'package:flutter_application_1/models/place_category.dart';
import 'package:flutter_application_1/widgets/rating_stars.dart';

void main() {
  test('Place is parsed from API JSON and serialized back', () {
    final place = Place.fromJson({
      'id': 7,
      'name': 'Štrbské pleso',
      'description': 'Prechádzka',
      'category': 'nature',
      'rating': 5,
      'latitude': 49.1193,
      'longitude': 20.0614,
      'photo': null,
      'is_favorite': true,
      'visited_at': '2026-07-02',
      'created_at': '2026-07-02 18:30:00',
    });

    expect(place.id, 7);
    expect(place.category, PlaceCategory.nature);
    expect(place.hasLocation, isTrue);
    expect(place.isFavorite, isTrue);
    expect(place.visitedAt, DateTime(2026, 7, 2));

    final json = place.toJson();
    expect(json['category'], 'nature');
    expect(json['visited_at'], '2026-07-02');
    expect(json['latitude'], 49.1193);
  });

  testWidgets('RatingStars reports the tapped star through onChanged', (
    tester,
  ) async {
    int? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RatingStars(rating: 2, onChanged: (value) => selected = value),
        ),
      ),
    );

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
    await tester.tap(find.byTooltip('4 / 5'));
    expect(selected, 4);
  });
}
