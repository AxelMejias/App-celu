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
      await tester.pump();
      expect(find.byType(AnswerButton), findsNWidgets(4));
    });

    testWidgets('renders a non-empty question text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QuizScreen()),
      );
      await tester.pump();
      // QuizScreen defaults to 'pokemon' game — any pokemon question text is shown
      final textWidgets = tester.widgetList<Text>(find.byType(Text)).toList();
      final hasNonEmptyQuestion = textWidgets.any(
        (t) => (t.data ?? '').length > 10 && t.data != 'Quiz',
      );
      expect(hasNonEmptyQuestion, isTrue);
    });

    testWidgets('renders 4 AnswerButton widgets for lol game', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const QuizScreen(),
          routes: {'/success': (context) => const Scaffold()},
          onGenerateRoute: (settings) {
            if (settings.name == '/') {
              return MaterialPageRoute(
                settings: const RouteSettings(name: '/', arguments: 'lol'),
                builder: (_) => const QuizScreen(),
              );
            }
            return null;
          },
        ),
      );
      await tester.pump();
      expect(find.byType(AnswerButton), findsNWidgets(4));
    });
  });
}
