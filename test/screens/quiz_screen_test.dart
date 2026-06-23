import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/screens/quiz_screen.dart';
import 'package:levelup_alarm/widgets/answer_button.dart';

void main() {
  group('QuizScreen', () {
    testWidgets('renders 4 AnswerButton widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QuizScreen()),
      );

      expect(find.byType(AnswerButton), findsNWidgets(4));
    });

    testWidgets('renders non-empty question text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QuizScreen()),
      );

      // The question text is a Text widget above the buttons; find any text that isn't an option
      expect(find.text('¿Cuántos Pokémon hay en la primera generación?'), findsOneWidget);
    });
  });
}
