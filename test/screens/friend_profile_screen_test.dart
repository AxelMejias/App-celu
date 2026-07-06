import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/challenge_question.dart';
import 'package:levelup_alarm/models/game_stats.dart';
import 'package:levelup_alarm/models/user_summary.dart';
import 'package:levelup_alarm/providers/challenges_provider.dart';
import 'package:levelup_alarm/screens/challenge_play_screen.dart';
import 'package:levelup_alarm/screens/friend_profile_screen.dart';
import 'package:levelup_alarm/services/challenge_service.dart';
import 'package:levelup_alarm/services/profile_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockProfileService extends Mock implements ProfileService {}

class MockChallengeService extends Mock implements ChallengeService {}

Widget _buildScreen(
  ProfileService profileService,
  UserSummary friend, {
  ChallengesProvider? challengesProvider,
}) {
  ChallengePlayArgs? capturedArgs;
  return ChangeNotifierProvider<ChallengesProvider>.value(
    value: challengesProvider ?? ChallengesProvider(challengeService: MockChallengeService(), uid: null),
    child: MaterialApp(
      home: FriendProfileScreen(friend: friend, profileService: profileService),
      onGenerateRoute: (settings) {
        if (settings.name == '/challenge-play') {
          capturedArgs = settings.arguments as ChallengePlayArgs;
          return MaterialPageRoute(
            builder: (_) => Scaffold(body: Text('play:${capturedArgs?.game}')),
          );
        }
        return null;
      },
    ),
  );
}

void main() {
  late MockProfileService mockService;
  const friend = UserSummary(uid: 'u2', username: 'misty');

  setUp(() {
    mockService = MockProfileService();
    when(() => mockService.loadProfile('u2')).thenAnswer(
      (_) async => UserProfile(username: 'misty', email: 'misty@example.com', stats: {}),
    );
  });

  testWidgets('muestra el username y las estadísticas del amigo', (tester) async {
    when(() => mockService.loadProfile('u2')).thenAnswer(
      (_) async => UserProfile(
        username: 'misty',
        email: 'misty@example.com',
        stats: {
          'pokemon': const GameStats(
            answered: 10,
            correct: 7,
            incorrect: 3,
            currentStreak: 2,
            bestStreak: 4,
          ),
        },
      ),
    );

    await tester.pumpWidget(_buildScreen(mockService, friend));
    await tester.pumpAndSettle();

    expect(find.text('misty'), findsWidgets);
    expect(find.textContaining('10'), findsWidgets);
  });

  testWidgets('muestra CircularProgressIndicator mientras carga', (tester) async {
    when(() => mockService.loadProfile('u2')).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return UserProfile(username: 'misty', email: 'misty@example.com', stats: {});
    });

    await tester.pumpWidget(_buildScreen(mockService, friend));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('no muestra el botón "Cerrar sesión"', (tester) async {
    await tester.pumpWidget(_buildScreen(mockService, friend));
    await tester.pumpAndSettle();

    expect(find.text('Cerrar sesión'), findsNothing);
  });

  testWidgets('tocar "Desafiar" y elegir un juego arma el set de preguntas y navega a jugar la ronda del proponente',
      (tester) async {
    final mockChallengeService = MockChallengeService();
    const builtQuestions = [
      ChallengeQuestion(text: 'q1', options: ['a', 'b'], correctIndex: 0),
    ];
    when(() => mockChallengeService.buildQuestionSet('pokemon')).thenReturn(builtQuestions);
    final challengesProvider = ChallengesProvider(challengeService: mockChallengeService, uid: 'u1');

    await tester.pumpWidget(
      _buildScreen(mockService, friend, challengesProvider: challengesProvider),
    );
    await tester.pumpAndSettle();
    // ProfileStatsView renders a per-game breakdown taller than the test
    // viewport, so the "Desafiar" button below it is outside the ListView's
    // initial cache extent and isn't built yet — scroll it into view first.
    await tester.dragUntilVisible(
      find.text('Desafiar'),
      find.byType(ListView),
      const Offset(0, -300),
    );

    await tester.tap(find.text('Desafiar'));
    await tester.pumpAndSettle();

    final gameOption = find.descendant(of: find.byType(BottomSheet), matching: find.text('Pokémon'));
    expect(gameOption, findsOneWidget);
    await tester.tap(gameOption);
    await tester.pumpAndSettle();

    expect(find.text('play:pokemon'), findsOneWidget);
    verify(() => mockChallengeService.buildQuestionSet('pokemon')).called(1);
  });
}
