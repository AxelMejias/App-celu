import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/game_stats.dart';

void main() {
  group('GameStats.empty', () {
    test('empty() has all counters at 0', () {
      final stats = GameStats.empty();

      expect(stats.answered, 0);
      expect(stats.correct, 0);
      expect(stats.incorrect, 0);
      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 0);
    });
  });

  group('GameStats.accuracy', () {
    test('accuracy returns correct/answered', () {
      const stats = GameStats(
        answered: 10,
        correct: 7,
        incorrect: 3,
        currentStreak: 0,
        bestStreak: 4,
      );

      expect(stats.accuracy, 0.7);
    });

    test('accuracy returns 0 when answered==0', () {
      final stats = GameStats.empty();

      expect(stats.accuracy, 0);
    });

    test('total is an alias for answered', () {
      const stats = GameStats(
        answered: 5,
        correct: 3,
        incorrect: 2,
        currentStreak: 1,
        bestStreak: 2,
      );

      expect(stats.total, 5);
    });
  });

  group('GameStats — serialization', () {
    test('toMap/fromMap round-trip preserves values', () {
      const stats = GameStats(
        answered: 8,
        correct: 6,
        incorrect: 2,
        currentStreak: 3,
        bestStreak: 5,
      );

      final rebuilt = GameStats.fromMap(stats.toMap());

      expect(rebuilt, stats);
    });

    test('fromMap con campos faltantes usa 0 por defecto', () {
      final stats = GameStats.fromMap({'answered': 4});

      expect(stats.answered, 4);
      expect(stats.correct, 0);
      expect(stats.incorrect, 0);
      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 0);
    });
  });
}
