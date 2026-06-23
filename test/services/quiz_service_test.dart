import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/data/pokemon_questions.dart';
import 'package:levelup_alarm/data/lol_questions.dart';
import 'package:levelup_alarm/services/quiz_service.dart';

void main() {
  late QuizService svc;

  setUp(() {
    svc = QuizService();
  });

  group('QuizService — getRandomQuestion game field', () {
    test('returns a pokemon question when game is "pokemon"', () {
      final q = svc.getRandomQuestion('pokemon');
      expect(q.game, 'pokemon');
    });

    test('returns a lol question when game is "lol"', () {
      final q = svc.getRandomQuestion('lol');
      expect(q.game, 'lol');
    });
  });

  group('QuizService — getRandomQuestion unknown game', () {
    test('throws ArgumentError for an unknown game', () {
      expect(() => svc.getRandomQuestion('unknown-game'), throwsArgumentError);
    });
  });

  group('QuizService — getRandomQuestion anti-repeat', () {
    test('two consecutive calls return different questions (bank > 1)', () {
      // pokemon bank has 22 questions — guaranteed to differ
      final q1 = svc.getRandomQuestion('pokemon');
      final q2 = svc.getRandomQuestion('pokemon');
      expect(q1.text, isNot(equals(q2.text)));
    });
  });

  group('QuizService — getRandomQuestions', () {
    test('returns 5 unique pokemon questions', () {
      final questions = svc.getRandomQuestions('pokemon', count: 5);
      expect(questions.length, 5);
      expect(questions.every((q) => q.game == 'pokemon'), isTrue);
      final texts = questions.map((q) => q.text).toSet();
      expect(texts.length, 5);
    });

    test('returns 3 unique lol questions', () {
      final questions = svc.getRandomQuestions('lol', count: 3);
      expect(questions.length, 3);
      expect(questions.every((q) => q.game == 'lol'), isTrue);
      final texts = questions.map((q) => q.text).toSet();
      expect(texts.length, 3);
    });

    test('throws ArgumentError for unknown game', () {
      expect(() => svc.getRandomQuestions('xyz'), throwsArgumentError);
    });

    test('result questions belong to the correct bank', () {
      final questions = svc.getRandomQuestions('pokemon', count: 3);
      for (final q in questions) {
        expect(pokemonQuestions.contains(q), isTrue);
      }
    });

    test('result questions for lol belong to lol bank', () {
      final questions = svc.getRandomQuestions('lol', count: 3);
      for (final q in questions) {
        expect(lolQuestions.contains(q), isTrue);
      }
    });
  });
}
