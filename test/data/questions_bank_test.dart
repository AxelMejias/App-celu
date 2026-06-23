import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/data/all_questions.dart';
import 'package:levelup_alarm/data/pokemon_questions.dart';
import 'package:levelup_alarm/data/lol_questions.dart';
import 'package:levelup_alarm/data/terraria_questions.dart';
import 'package:levelup_alarm/data/valorant_questions.dart';
import 'package:levelup_alarm/data/overwatch_questions.dart';
import 'package:levelup_alarm/data/warframe_questions.dart';

void main() {
  group('Questions Bank — minimums', () {
    test('pokemonQuestions has at least 20 questions', () {
      expect(pokemonQuestions.length, greaterThanOrEqualTo(20));
    });

    test('lolQuestions has at least 20 questions', () {
      expect(lolQuestions.length, greaterThanOrEqualTo(20));
    });

    test('terrariaQuestions has at least 15 questions', () {
      expect(terrariaQuestions.length, greaterThanOrEqualTo(15));
    });

    test('valorantQuestions has at least 15 questions', () {
      expect(valorantQuestions.length, greaterThanOrEqualTo(15));
    });

    test('overwatchQuestions has at least 15 questions', () {
      expect(overwatchQuestions.length, greaterThanOrEqualTo(15));
    });

    test('warframeQuestions has at least 15 questions', () {
      expect(warframeQuestions.length, greaterThanOrEqualTo(15));
    });
  });

  group('Questions Bank — correctIndex validity', () {
    test('all questions in every bank have correctIndex in range 0–3', () {
      for (final entry in questionsByGame.entries) {
        for (final q in entry.value) {
          expect(
            q.correctIndex,
            allOf(greaterThanOrEqualTo(0), lessThanOrEqualTo(3)),
            reason: 'game=${entry.key}, question="${q.text}"',
          );
        }
      }
    });
  });

  group('Questions Bank — aggregator', () {
    test('questionsByGame contains all 6 canonical game IDs', () {
      expect(questionsByGame.keys, containsAll(['pokemon', 'lol', 'terraria', 'valorant', 'overwatch', 'warframe']));
      expect(questionsByGame.length, equals(6));
    });

    test('questionsByGame["pokemon"] returns pokemonQuestions', () {
      expect(questionsByGame['pokemon'], equals(pokemonQuestions));
    });
  });
}
