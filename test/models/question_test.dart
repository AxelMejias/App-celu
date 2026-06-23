import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/question.dart';

void main() {
  group('Question', () {
    test('options[correctIndex] returns correct option for index 0', () {
      const q = Question(
        game: 'pokemon',
        text: '?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        difficulty: 'easy',
      );

      expect(q.options[q.correctIndex], equals('A'));
    });

    test('options[correctIndex] returns correct option for index 3', () {
      const q = Question(
        game: 'pokemon',
        text: '?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 3,
        difficulty: 'easy',
      );

      expect(q.options[q.correctIndex], equals('D'));
    });

    test('difficulty "easy" is stored correctly', () {
      const q = Question(
        game: 'lol',
        text: '?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        difficulty: 'easy',
      );
      expect(q.difficulty, equals('easy'));
    });

    test('difficulty "medium" is stored correctly', () {
      const q = Question(
        game: 'lol',
        text: '?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        difficulty: 'medium',
      );
      expect(q.difficulty, equals('medium'));
    });

    test('difficulty "hard" is stored correctly', () {
      const q = Question(
        game: 'lol',
        text: '?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        difficulty: 'hard',
      );
      expect(q.difficulty, equals('hard'));
    });

    test('game is preserved from construction', () {
      const q = Question(
        game: 'valorant',
        text: '?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 1,
        difficulty: 'easy',
      );
      expect(q.game, equals('valorant'));
    });
  });
}
