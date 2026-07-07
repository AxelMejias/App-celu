import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/challenge.dart';
import 'package:levelup_alarm/models/challenge_question.dart';
import 'package:levelup_alarm/providers/challenges_provider.dart';
import 'package:levelup_alarm/screens/challenges_screen.dart';
import 'package:levelup_alarm/services/challenge_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockChallengeService extends Mock implements ChallengeService {}

const questions = [
  ChallengeQuestion(text: 'q1', options: ['a', 'b'], correctIndex: 0),
];

Challenge _buildChallenge({
  String challengeId = 'ch1',
  String fromUid = 'u2',
  String fromUsername = 'misty',
  String toUid = 'u1',
  String status = 'pending',
  int fromScore = 3,
  int? toScore,
  String? winnerUid,
  bool isDraw = false,
}) {
  return Challenge(
    challengeId: challengeId,
    game: 'pokemon',
    fromUid: fromUid,
    fromUsername: fromUsername,
    toUid: toUid,
    toUsername: 'ash',
    questions: questions,
    fromScore: fromScore,
    toScore: toScore,
    status: status,
    winnerUid: winnerUid,
    isDraw: isDraw,
  );
}

Widget _wrap(ChallengesProvider provider) {
  return ChangeNotifierProvider<ChallengesProvider>.value(
    value: provider,
    child: const MaterialApp(home: ChallengesScreen()),
  );
}

void main() {
  late MockChallengeService mockService;

  setUp(() {
    mockService = MockChallengeService();
  });

  testWidgets('lista los desafíos recibidos pendientes con el username del proponente y una acción Jugar',
      (tester) async {
    when(() => mockService.loadIncoming('u1'))
        .thenAnswer((_) async => [_buildChallenge(fromUsername: 'misty')]);
    when(() => mockService.loadSent('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadHistory('u1')).thenAnswer((_) async => []);
    final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    expect(find.text('misty'), findsWidgets);
    expect(find.text('Jugar'), findsOneWidget);
  });

  testWidgets('muestra estado vacío cuando no hay desafíos', (tester) async {
    when(() => mockService.loadIncoming('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadSent('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadHistory('u1')).thenAnswer((_) async => []);
    final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    expect(find.textContaining('No tenés desafíos'), findsOneWidget);
  });

  testWidgets('muestra un indicador de carga cuando isLoading es true y no hay desafíos',
      (tester) async {
    final incomingCompleter = Completer<List<Challenge>>();
    when(() => mockService.loadIncoming('u1')).thenAnswer((_) => incomingCompleter.future);
    when(() => mockService.loadSent('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadHistory('u1')).thenAnswer((_) async => []);
    final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

    await tester.pumpWidget(_wrap(provider));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('No tenés desafíos'), findsNothing);

    incomingCompleter.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('muestra el estado vacío solo cuando terminó de cargar y no hay desafíos',
      (tester) async {
    when(() => mockService.loadIncoming('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadSent('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadHistory('u1')).thenAnswer((_) async => []);
    final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('No tenés desafíos'), findsOneWidget);
  });

  testWidgets('con desafíos no muestra ni el indicador ni el estado vacío', (tester) async {
    when(() => mockService.loadIncoming('u1'))
        .thenAnswer((_) async => [_buildChallenge(fromUsername: 'misty')]);
    when(() => mockService.loadSent('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadHistory('u1')).thenAnswer((_) async => []);
    final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('No tenés desafíos'), findsNothing);
  });

  testWidgets('pull-to-refresh vuelve a invocar ChallengesProvider.loadAll', (tester) async {
    when(() => mockService.loadIncoming('u1'))
        .thenAnswer((_) async => [_buildChallenge(fromUsername: 'misty')]);
    when(() => mockService.loadSent('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadHistory('u1')).thenAnswer((_) async => []);
    final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();
    clearInteractions(mockService);
    when(() => mockService.loadIncoming('u1'))
        .thenAnswer((_) async => [_buildChallenge(fromUsername: 'misty')]);
    when(() => mockService.loadSent('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadHistory('u1')).thenAnswer((_) async => []);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    verify(() => mockService.loadIncoming('u1')).called(1);
    verify(() => mockService.loadSent('u1')).called(1);
    verify(() => mockService.loadHistory('u1')).called(1);
  });

  testWidgets('el historial muestra un desafío ganado como ganado (y perdido/empate según el resultado)',
      (tester) async {
    when(() => mockService.loadIncoming('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadSent('u1')).thenAnswer((_) async => []);
    when(() => mockService.loadHistory('u1')).thenAnswer(
      (_) async => [
        _buildChallenge(
          challengeId: 'won',
          fromUid: 'u2',
          toUid: 'u1',
          status: 'completed',
          fromScore: 1,
          toScore: 3,
          winnerUid: 'u1',
        ),
        _buildChallenge(
          challengeId: 'lost',
          fromUid: 'u2',
          toUid: 'u1',
          status: 'completed',
          fromScore: 5,
          toScore: 1,
          winnerUid: 'u2',
        ),
        _buildChallenge(
          challengeId: 'draw',
          fromUid: 'u2',
          toUid: 'u1',
          status: 'completed',
          fromScore: 2,
          toScore: 2,
          isDraw: true,
        ),
      ],
    );
    final provider = ChallengesProvider(challengeService: mockService, uid: 'u1');

    await tester.pumpWidget(_wrap(provider));
    await tester.pumpAndSettle();

    expect(find.textContaining('Ganaste'), findsOneWidget);
    expect(find.textContaining('Perdiste'), findsOneWidget);
    expect(find.textContaining('Empate'), findsOneWidget);
  });
}
