import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/widgets/answer_button.dart';

void main() {
  group('AnswerButton', () {
    testWidgets('renders provided text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerButton(
              text: 'Charizard',
              onPressed: () {},
              color: Colors.purple,
            ),
          ),
        ),
      );

      expect(find.text('Charizard'), findsOneWidget);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnswerButton(
              text: 'Pikachu',
              onPressed: null,
              color: Colors.blue,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
