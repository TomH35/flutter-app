import 'package:flutter_test/flutter_test.dart';

import 'package:adv_basics/data/questions.dart';
import 'package:adv_basics/quiz.dart';

void main() {
  testWidgets('Quiz goes from start to results and restarts',
      (WidgetTester tester) async {
    await tester.pumpWidget(const Quiz());

    expect(find.text('Start Quiz'), findsOneWidget);

    await tester.tap(find.text('Start Quiz'));
    await tester.pump();

    // Always pick the correct answer (the first one in the data).
    for (final question in questions) {
      expect(find.text(question.text), findsOneWidget);
      await tester.tap(find.text(question.answers[0]));
      await tester.pump();
    }

    expect(
      find.text(
        'You answered ${questions.length} out of ${questions.length} questions correctly!',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Restart Quiz'));
    await tester.pump();

    expect(find.text(questions[0].text), findsOneWidget);
  });
}
