import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/challenge.dart';
import 'package:levelup_alarm/models/challenge_question.dart';
import 'package:levelup_alarm/models/user_summary.dart';
import 'package:levelup_alarm/services/challenge_service.dart';
import 'package:levelup_alarm/services/quiz_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ChallengeService service;

  const questions = [
    ChallengeQuestion(text: 'q1', options: ['a', 'b'], correctIndex: 0),
    ChallengeQuestion(text: 'q2', options: ['c', 'd'], correctIndex: 1),
  ];
  const opponent = UserSummary(uid: 'u2', username: 'misty');

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = ChallengeService(firestore: firestore, quizService: QuizService());
  });

  group('ChallengeService.createChallenge', () {
    test('escribe un doc en challenges con las preguntas embebidas, fromScore cargado, toScore null y status pending', () async {
      final challenge = await service.createChallenge(
        fromUid: 'u1',
        fromUsername: 'ash',
        opponent: opponent,
        game: 'pokemon',
        fromScore: 2,
        questions: questions,
      );

      final snapshot = await firestore.collection('challenges').get();
      expect(snapshot.docs, hasLength(1));
      final data = snapshot.docs.first.data();
      expect(data['questions'], hasLength(2));
      expect(data['fromScore'], 2);
      expect(data['toScore'], isNull);
      expect(data['status'], 'pending');
      expect(data['fromUid'], 'u1');
      expect(data['fromUsername'], 'ash');
      expect(data['toUid'], 'u2');
      expect(data['toUsername'], 'misty');
      expect(challenge.challengeId, isNotEmpty);
    });

    test('el desafío creado nace con winnerUid null, isDraw false y completedAt null', () async {
      final challenge = await service.createChallenge(
        fromUid: 'u1',
        fromUsername: 'ash',
        opponent: opponent,
        game: 'pokemon',
        fromScore: 2,
        questions: questions,
      );

      expect(challenge.winnerUid, isNull);
      expect(challenge.isDraw, isFalse);
      expect(challenge.completedAt, isNull);
    });
  });

  group('ChallengeService.buildQuestionSet', () {
    test('devuelve preguntas del juego pedido', () {
      final result = service.buildQuestionSet('pokemon');

      expect(result, isNotEmpty);
      expect(result.length, kChallengeQuestionCount);
      for (final q in result) {
        expect(q.text, isNotEmpty);
      }
    });
  });

  Future<Challenge> seedChallenge({
    required String fromUid,
    required String toUid,
    String status = 'pending',
  }) async {
    return service.createChallenge(
      fromUid: fromUid,
      fromUsername: 'ash',
      opponent: UserSummary(uid: toUid, username: 'misty'),
      game: 'pokemon',
      fromScore: 2,
      questions: questions,
    );
  }

  group('ChallengeService.loadIncoming', () {
    test('devuelve solo desafíos con toUid == uid y status pending', () async {
      await seedChallenge(fromUid: 'u1', toUid: 'u2');
      await seedChallenge(fromUid: 'u3', toUid: 'u4');

      final results = await service.loadIncoming('u2');

      expect(results, hasLength(1));
      expect(results.first.toUid, 'u2');
    });

    test('ignora los completed y los dirigidos a otro usuario', () async {
      final completed = await seedChallenge(fromUid: 'u1', toUid: 'u2');
      await service.submitOpponentScore(challenge: completed, score: 1);
      await seedChallenge(fromUid: 'u3', toUid: 'u4');

      final results = await service.loadIncoming('u2');

      expect(results, isEmpty);
    });

    test('sin desafíos devuelve lista vacía', () async {
      final results = await service.loadIncoming('u2');

      expect(results, isEmpty);
    });
  });

  group('ChallengeService.loadSent', () {
    test('devuelve los desafíos con fromUid == uid y status pending', () async {
      await seedChallenge(fromUid: 'u1', toUid: 'u2');
      await seedChallenge(fromUid: 'u3', toUid: 'u4');

      final results = await service.loadSent('u1');

      expect(results, hasLength(1));
      expect(results.first.fromUid, 'u1');
    });
  });

  group('ChallengeService.loadHistory', () {
    test('devuelve solo los completed en los que el usuario es from o to', () async {
      final asProposer = await seedChallenge(fromUid: 'u1', toUid: 'u2');
      await service.submitOpponentScore(challenge: asProposer, score: 1);
      final asOpponent = await seedChallenge(fromUid: 'u3', toUid: 'u1');
      await service.submitOpponentScore(challenge: asOpponent, score: 1);
      await seedChallenge(fromUid: 'u1', toUid: 'u5'); // still pending

      final results = await service.loadHistory('u1');

      expect(results, hasLength(2));
      expect(results.every((c) => c.status == 'completed'), isTrue);
    });

    test('excluye los pendientes y sin completados devuelve lista vacía', () async {
      await seedChallenge(fromUid: 'u1', toUid: 'u2');

      final results = await service.loadHistory('u1');

      expect(results, isEmpty);
    });
  });

  group('ChallengeService.submitOpponentScore', () {
    test('setea toScore, status completed, completedAt y resuelve winnerUid según los puntajes', () async {
      final challenge = await seedChallenge(fromUid: 'u1', toUid: 'u2');

      await service.submitOpponentScore(challenge: challenge, score: 1);

      final doc = await firestore.collection('challenges').doc(challenge.challengeId).get();
      final data = doc.data()!;
      expect(data['toScore'], 1);
      expect(data['status'], 'completed');
      expect(data['completedAt'], isNotNull);
      expect(data['winnerUid'], 'u1'); // fromScore 2 > toScore 1
    });

    test('con score > fromScore deja winnerUid = toUid', () async {
      final challenge = await seedChallenge(fromUid: 'u1', toUid: 'u2');

      await service.submitOpponentScore(challenge: challenge, score: 5);

      final doc = await firestore.collection('challenges').doc(challenge.challengeId).get();
      expect(doc.data()!['winnerUid'], 'u2');
    });

    test('con empate deja winnerUid null e isDraw true', () async {
      final challenge = await seedChallenge(fromUid: 'u1', toUid: 'u2');

      await service.submitOpponentScore(challenge: challenge, score: 2);

      final doc = await firestore.collection('challenges').doc(challenge.challengeId).get();
      expect(doc.data()!['winnerUid'], isNull);
      expect(doc.data()!['isDraw'], isTrue);
    });
  });

  group('ChallengeService.loadUsername', () {
    test('devuelve el username del documento users/{uid}', () async {
      await firestore.collection('users').doc('u1').set({'uid': 'u1', 'username': 'ash'});

      final username = await service.loadUsername('u1');

      expect(username, 'ash');
    });

    test('devuelve cadena vacía si el documento no tiene username', () async {
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});

      final username = await service.loadUsername('u1');

      expect(username, '');
    });
  });
}
