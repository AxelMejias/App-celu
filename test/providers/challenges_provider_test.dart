import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/challenge.dart';
import 'package:levelup_alarm/models/challenge_question.dart';
import 'package:levelup_alarm/models/user_summary.dart';
import 'package:levelup_alarm/providers/challenges_provider.dart';
import 'package:levelup_alarm/services/challenge_service.dart';
import 'package:mocktail/mocktail.dart';

class MockChallengeService extends Mock implements ChallengeService {}

Challenge _buildChallenge({
  String challengeId = 'ch1',
  String fromUid = 'u1',
  String toUid = 'u2',
  String status = 'pending',
}) {
  return Challenge(
    challengeId: challengeId,
    game: 'pokemon',
    fromUid: fromUid,
    fromUsername: 'ash',
    toUid: toUid,
    toUsername: 'misty',
    questions: const [
      ChallengeQuestion(text: 'q1', options: ['a', 'b'], correctIndex: 0),
    ],
    fromScore: 1,
    status: status,
  );
}

void main() {
  late MockChallengeService mockService;
  const opponent = UserSummary(uid: 'u2', username: 'misty');
  const questions = [
    ChallengeQuestion(text: 'q1', options: ['a', 'b'], correctIndex: 0),
  ];

  setUpAll(() {
    registerFallbackValue(opponent);
    registerFallbackValue(_buildChallenge());
  });

  setUp(() {
    mockService = MockChallengeService();
  });

  group('ChallengesProvider.loadAll', () {
    test('popula incoming, sent e history y deja isLoading en false', () async {
      when(() => mockService.loadIncoming('u1')).thenAnswer((_) async => [_buildChallenge()]);
      when(() => mockService.loadSent('u1')).thenAnswer((_) async => [_buildChallenge()]);
      when(() => mockService.loadHistory('u1'))
          .thenAnswer((_) async => [_buildChallenge(status: 'completed')]);
      final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

      await provider.loadAll();

      expect(provider.incoming, hasLength(1));
      expect(provider.sent, hasLength(1));
      expect(provider.history, hasLength(1));
      expect(provider.isLoading, isFalse);
    });

    test('un fallo del servicio setea errorMessage en español e isLoading en false', () async {
      when(() => mockService.loadIncoming('u1')).thenThrow(Exception('boom'));
      when(() => mockService.loadSent('u1')).thenAnswer((_) async => []);
      when(() => mockService.loadHistory('u1')).thenAnswer((_) async => []);
      final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

      await provider.loadAll();

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
    });
  });

  group('ChallengesProvider.propose', () {
    test('obtiene el username propio cacheado y llama createChallenge con opponent, game, fromScore y questions', () async {
      when(() => mockService.loadUsername('u1')).thenAnswer((_) async => 'ash');
      when(() => mockService.createChallenge(
            fromUid: any(named: 'fromUid'),
            fromUsername: any(named: 'fromUsername'),
            opponent: any(named: 'opponent'),
            game: any(named: 'game'),
            fromScore: any(named: 'fromScore'),
            questions: any(named: 'questions'),
          )).thenAnswer((_) async => _buildChallenge());
      when(() => mockService.loadSent('u1')).thenAnswer((_) async => [_buildChallenge()]);
      final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

      await provider.propose(opponent: opponent, game: 'pokemon', questions: questions, fromScore: 3);

      verify(() => mockService.createChallenge(
            fromUid: 'u1',
            fromUsername: 'ash',
            opponent: opponent,
            game: 'pokemon',
            fromScore: 3,
            questions: questions,
          )).called(1);
      expect(provider.sent, hasLength(1));
    });

    test('con uid null es no-op (no llama al servicio)', () async {
      final provider = ChallengesProvider(challengeService: mockService, uid: null);

      await provider.propose(opponent: opponent, game: 'pokemon', questions: questions, fromScore: 3);

      verifyNever(() => mockService.createChallenge(
            fromUid: any(named: 'fromUid'),
            fromUsername: any(named: 'fromUsername'),
            opponent: any(named: 'opponent'),
            game: any(named: 'game'),
            fromScore: any(named: 'fromScore'),
            questions: any(named: 'questions'),
          ));
    });
  });

  group('ChallengesProvider.buildQuestionSet', () {
    test('delega en ChallengeService.buildQuestionSet', () {
      when(() => mockService.buildQuestionSet('pokemon')).thenReturn(questions);
      final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

      final result = provider.buildQuestionSet('pokemon');

      expect(result, questions);
    });
  });

  group('ChallengesProvider.submitScore', () {
    test('llama submitOpponentScore y saca el desafío de incoming / lo agrega a history', () async {
      final challenge = _buildChallenge();
      when(() => mockService.submitOpponentScore(challenge: any(named: 'challenge'), score: any(named: 'score')))
          .thenAnswer((_) async {});
      when(() => mockService.loadIncoming('u2')).thenAnswer((_) async => [challenge]);
      when(() => mockService.loadSent('u2')).thenAnswer((_) async => []);
      when(() => mockService.loadHistory('u2')).thenAnswer((_) async => []);
      final provider = ChallengesProvider(challengeService: mockService, uid: 'u2');
      await provider.loadAll();

      await provider.submitScore(challenge, 4);

      verify(() => mockService.submitOpponentScore(challenge: challenge, score: 4)).called(1);
      expect(provider.incoming, isEmpty);
      expect(provider.history, hasLength(1));
    });

    test('sobre un desafío ya completed es no-op', () async {
      final completed = _buildChallenge(status: 'completed');
      final provider = ChallengesProvider(challengeService: mockService, uid: 'u2');

      await provider.submitScore(completed, 4);

      verifyNever(() => mockService.submitOpponentScore(challenge: any(named: 'challenge'), score: any(named: 'score')));
    });
  });
}
