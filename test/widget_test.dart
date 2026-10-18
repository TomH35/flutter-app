import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/earthquake_model.dart';
import 'package:flutter_application_1/providers/app_data_provider.dart';

void main() {
  test('EarthquakeModel parses a USGS GeoJSON response', () {
    final model = EarthquakeModel.fromJson({
      'type': 'FeatureCollection',
      'metadata': {'count': 1},
      'features': [
        {
          'type': 'Feature',
          'id': 'us123',
          'properties': {
            'mag': 5.4,
            'place': '10 km N of Somewhere',
            'time': 1700000000000,
            'alert': 'green',
          },
          'geometry': {
            'type': 'Point',
            'coordinates': [12.5, 41.9, 10],
          },
        },
      ],
    });

    final quake = model.features!.single;
    expect(quake.properties!.mag, 5.4);
    expect(quake.properties!.place, '10 km N of Somewhere');
    expect(quake.geometry!.coordinates, [12.5, 41.9, 10]);
  });

  testWidgets('Home page shows an error with retry when loading fails',
      (WidgetTester tester) async {
    // In widget tests every HTTP request returns status 400.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (ctx) => AppDataProvider(),
        child: const MyApp(),
      ),
    );
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 1)));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Earthquake App'), findsOneWidget);
    expect(find.text('Server error: 400'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
