import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:todo_app/main.dart';
import 'package:todo_app/todo_provider.dart';

void main() {
  testWidgets('Add, complete and delete a todo', (WidgetTester tester) async {
    final provider = TodoProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: provider, child: const MyApp()),
    );

    expect(find.text('Nothing to do!'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.text('Input field must not be empty'), findsOneWidget);
    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.tap(find.byType(Radio<TodoPriority>).last);
    await tester.pump();
    expect(provider.priority, TodoPriority.high);

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('Priority: High'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(provider.todos.single.completed, isTrue);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pump();
    expect(provider.todos, isEmpty);
    expect(find.text('Nothing to do!'), findsOneWidget);
  });
}
