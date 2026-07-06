import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/challenge_question.dart';
import 'package:levelup_alarm/models/question.dart';

void main() {
  group('ChallengeQuestion.fromMap/toMap', () {
    test('round-trip preserva text, options y correctIndex', () {
      const question = ChallengeQuestion(
        text: '¿Quién es el mejor entrenador?',
        options: ['Ash', 'Misty', 'Brock', 'Gary'],
        correctIndex: 0,
      );

      final map = question.toMap();
      final rebuilt = ChallengeQuestion.fromMap(map);

      expect(rebuilt.text, question.text);
      expect(rebuilt.options, question.options);
      expect(rebuilt.correctIndex, question.correctIndex);
    });

    test('fromMap sin options usa lista vacía', () {
      final rebuilt = ChallengeQuestion.fromMap({
        'text': '¿Pregunta?',
        'correctIndex': 1,
      });

      expect(rebuilt.options, isEmpty);
    });
  });

  group('ChallengeQuestion.fromQuestion', () {
    test('copia text/options/correctIndex de una Question', () {
      const original = Question(
        game: 'pokemon',
        text: '¿Quién es el mejor entrenador?',
        options: ['Ash', 'Misty', 'Brock', 'Gary'],
        correctIndex: 0,
        difficulty: 'easy',
      );

      final challengeQuestion = ChallengeQuestion.fromQuestion(original);

      expect(challengeQuestion.text, original.text);
      expect(challengeQuestion.options, original.options);
      expect(challengeQuestion.correctIndex, original.correctIndex);
    });
  });

  group('ChallengeQuestion equality', () {
    test('dos instancias con los mismos valores son ==', () {
      const a = ChallengeQuestion(text: 'q', options: ['a', 'b'], correctIndex: 0);
      const b = ChallengeQuestion(text: 'q', options: ['a', 'b'], correctIndex: 0);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
