import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/challenge.dart';
import 'package:levelup_alarm/models/challenge_question.dart';
import 'package:levelup_alarm/models/user_summary.dart';
import 'package:levelup_alarm/providers/challenges_provider.dart';
import 'package:levelup_alarm/screens/challenge_play_screen.dart';
import 'package:levelup_alarm/services/challenge_service.dart';
import 'package:levelup_alarm/widgets/answer_button.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockChallengeService extends Mock implements ChallengeService {}

const questions = [
  ChallengeQuestion(text: 'q1', options: ['a', 'b'], correctIndex: 0),
  ChallengeQuestion(text: 'q2', options: ['c', 'd'], correctIndex: 1),
];

const opponent = UserSummary(uid: 'u2', username: 'misty');

Challenge _buildChallenge() => Challenge(
      challengeId: 'ch1',
      game: 'pokemon',
      fromUid: 'u2',
      fromUsername: 'misty',
      toUid: 'u1',
      toUsername: 'ash',
      questions: questions,
      fromScore: 1,
      status: 'pending',
    );

Widget _wrap(Widget child, ChallengesProvider provider) {
  return ChangeNotifierProvider<ChallengesProvider>.value(
    value: provider,
    child: MaterialApp(home: child),
  );
}

void main() {
  late MockChallengeService mockService;

  setUpAll(() {
    registerFallbackValue(opponent);
    registerFallbackValue(_buildChallenge());
  });

  setUp(() {
    mockService = MockChallengeService();
  });

  testWidgets('modo responder: contestar todas las preguntas embebidas cuenta los aciertos como puntaje', (tester) async {
    when(() => mockService.submitOpponentScore(challenge: any(named: 'challenge'), score: any(named: 'score')))
        .thenAnswer((_) async {});
    final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

    await tester.pumpWidget(_wrap(
      ChallengePlayScreen(args: ChallengePlayArgs.respond(_buildChallenge())),
      provider,
    ));
    await tester.pump();

    // Answer q1 correctly (index 0), then q2 correctly (index 1)
    await tester.tap(find.byType(AnswerButton).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AnswerButton).at(1));
    await tester.pumpAndSettle();

    verify(() => mockService.submitOpponentScore(challenge: any(named: 'challenge'), score: 2)).called(1);
  });

  testWidgets('modo proponer: al terminar llama propose(opponent, game, questions, fromScore)', (tester) async {
    when(() => mockService.loadUsername('u1')).thenAnswer((_) async => 'ash');
    when(() => mockService.createChallenge(
          fromUid: any(named: 'fromUid'),
          fromUsername: any(named: 'fromUsername'),
          opponent: any(named: 'opponent'),
          game: any(named: 'game'),
          fromScore: any(named: 'fromScore'),
          questions: any(named: 'questions'),
        )).thenAnswer((_) async => _buildChallenge());
    when(() => mockService.loadSent('u1')).thenAnswer((_) async => []);
    final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

    await tester.pumpWidget(_wrap(
      ChallengePlayScreen(
        args: ChallengePlayArgs.propose(opponent: opponent, game: 'pokemon', questions: questions),
      ),
      provider,
    ));
    await tester.pump();

    await tester.tap(find.byType(AnswerButton).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AnswerButton).at(0)); // wrong answer for q2 (correct is index 1)
    await tester.pumpAndSettle();

    verify(() => mockService.createChallenge(
          fromUid: 'u1',
          fromUsername: 'ash',
          opponent: opponent,
          game: 'pokemon',
          fromScore: 1,
          questions: questions,
        )).called(1);
  });
}
