import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/challenge.dart';
import 'package:levelup_alarm/models/challenge_question.dart';

void main() {
  const questions = [
    ChallengeQuestion(text: 'q1', options: ['a', 'b'], correctIndex: 0),
    ChallengeQuestion(text: 'q2', options: ['c', 'd'], correctIndex: 1),
  ];

  group('Challenge.fromMap/toMap', () {
    test('round-trip preserva escalares y la lista de ChallengeQuestion embebida', () {
      final challenge = Challenge(
        challengeId: 'ch1',
        game: 'pokemon',
        fromUid: 'u1',
        fromUsername: 'ash',
        toUid: 'u2',
        toUsername: 'misty',
        questions: questions,
        fromScore: 2,
        toScore: 1,
        status: 'completed',
        winnerUid: 'u1',
        isDraw: false,
        createdAt: DateTime(2026, 1, 1),
        completedAt: DateTime(2026, 1, 2),
      );

      final map = challenge.toMap();
      final rebuilt = Challenge.fromMap(map, id: 'ch1');

      expect(rebuilt.challengeId, 'ch1');
      expect(rebuilt.game, 'pokemon');
      expect(rebuilt.fromUid, 'u1');
      expect(rebuilt.fromUsername, 'ash');
      expect(rebuilt.toUid, 'u2');
      expect(rebuilt.toUsername, 'misty');
      expect(rebuilt.questions, questions);
      expect(rebuilt.fromScore, 2);
      expect(rebuilt.toScore, 1);
      expect(rebuilt.status, 'completed');
      expect(rebuilt.winnerUid, 'u1');
      expect(rebuilt.isDraw, isFalse);
    });

    test('fromMap de un desafío pending deja toScore, winnerUid y completedAt nulos e isDraw false', () {
      final rebuilt = Challenge.fromMap({
        'game': 'pokemon',
        'fromUid': 'u1',
        'fromUsername': 'ash',
        'toUid': 'u2',
        'toUsername': 'misty',
        'questions': questions.map((q) => q.toMap()).toList(),
        'fromScore': 2,
        'status': 'pending',
      }, id: 'ch1');

      expect(rebuilt.toScore, isNull);
      expect(rebuilt.winnerUid, isNull);
      expect(rebuilt.isDraw, isFalse);
      expect(rebuilt.completedAt, isNull);
    });
  });

  group('resolveWinner', () {
    test('gana el proponente cuando fromScore > toScore', () {
      final result = resolveWinner(fromScore: 4, toScore: 2, fromUid: 'u1', toUid: 'u2');

      expect(result.winnerUid, 'u1');
      expect(result.isDraw, isFalse);
    });

    test('gana el rival cuando toScore > fromScore', () {
      final result = resolveWinner(fromScore: 3, toScore: 5, fromUid: 'u1', toUid: 'u2');

      expect(result.winnerUid, 'u2');
      expect(result.isDraw, isFalse);
    });

    test('empate cuando fromScore == toScore (winnerUid null, isDraw true)', () {
      final result = resolveWinner(fromScore: 3, toScore: 3, fromUid: 'u1', toUid: 'u2');

      expect(result.winnerUid, isNull);
      expect(result.isDraw, isTrue);
    });
  });
}
