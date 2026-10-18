import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/screens/tabs.dart';

// TabsScreen is pumped with the default theme, because GoogleFonts would try
// to download the Lato font, and widget tests have no network access.
Widget buildApp() => const MaterialApp(home: TabsScreen());

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Favorite a meal and find it in the Favorites tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Categories'), findsWidgets);

    await tester.tap(find.text('Cestoviny & Rizotá'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Špagety s paradajkovou omáčkou'));
    await tester.pumpAndSettle();

    expect(find.text('Ingredients'), findsOneWidget);

    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pump();
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    expect(find.text('Meal added to favorites!'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Your Favorites'), findsOneWidget);
    expect(find.text('Špagety s paradajkovou omáčkou'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('favorite_meal_ids'), ['m1']);
  });

  testWidgets('Filters are returned to TabsScreen and saved',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vegan'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Your Filters'), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('vegan'), isTrue);
  });
}
