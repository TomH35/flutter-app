import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/hurdle_provider.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Guessing the target word shows the win dialog',
      (WidgetTester tester) async {
    final provider = HurdleProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const WordHurdleApp(),
      ),
    );

    expect(find.text('Word Hurdle'), findsOneWidget);
    expect(find.text('Attempts: 0/6'), findsOneWidget);

    await tester.tap(find.text('SUBMIT'));
    await tester.pump();
    expect(find.text('Enter all 5 letters'), findsOneWidget);

    for (final letter in 'QQQQQ'.split('')) {
      await tester.tap(find.widgetWithText(ElevatedButton, letter));
    }
    await tester.tap(find.text('SUBMIT'));
    await tester.pump();
    expect(find.text('Not a word in my dictionary'), findsOneWidget);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('DELETE'));
    }
    await tester.pump();

    for (final letter in provider.targetWord.split('')) {
      await tester.tap(find.widgetWithText(ElevatedButton, letter));
    }
    await tester.tap(find.text('SUBMIT'));
    await tester.pumpAndSettle();

    expect(find.text('You Win!!!'), findsOneWidget);
    expect(find.text('The word was ${provider.targetWord}'), findsOneWidget);

    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();

    expect(find.text('You Win!!!'), findsNothing);
    expect(provider.wins, isFalse);
    expect(provider.index, 0);
  });
}
