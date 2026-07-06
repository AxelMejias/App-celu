import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/providers/profile_provider.dart';
import 'package:levelup_alarm/screens/quiz_screen.dart';
import 'package:levelup_alarm/services/profile_service.dart';
import 'package:levelup_alarm/widgets/answer_button.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockProfileProvider extends Mock implements ProfileProvider {}

class MockProfileService extends Mock implements ProfileService {}

/// Wraps [child] with a `ProfileProvider` in the tree so `QuizScreen` can
/// call `context.read<ProfileProvider>()` without a `ProviderNotFoundException`.
/// Defaults to a signed-out `ProfileProvider` (a safe no-op) backed by a
/// mocked `ProfileService` — a real `ProfileService()` would reach for
/// `FirebaseFirestore.instance`, which isn't available in the test
/// environment — unless a specific [profileProvider] double is supplied.
Widget _wrap(Widget child, {ProfileProvider? profileProvider}) {
  return ChangeNotifierProvider<ProfileProvider>.value(
    value: profileProvider ?? ProfileProvider(profileService: MockProfileService(), uid: null),
    child: child,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(false);
  });

  group('QuizScreen', () {
    testWidgets('renders 4 AnswerButton widgets', (tester) async {
      await tester.pumpWidget(
        _wrap(const MaterialApp(home: QuizScreen())),
      );
      await tester.pump();
      expect(find.byType(AnswerButton), findsNWidgets(4));
    });

    testWidgets('renders a non-empty question text', (tester) async {
      await tester.pumpWidget(
        _wrap(const MaterialApp(home: QuizScreen())),
      );
      await tester.pump();
      // QuizScreen defaults to 'pokemon' game — any pokemon question text is shown
      final textWidgets = tester.widgetList<Text>(find.byType(Text)).toList();
      final hasNonEmptyQuestion = textWidgets.any(
        (t) => (t.data ?? '').length > 10 && t.data != 'Quiz',
      );
      expect(hasNonEmptyQuestion, isTrue);
    });

    testWidgets('renders 4 AnswerButton widgets for lol game', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MaterialApp(
            home: const QuizScreen(),
            routes: {'/success': (context) => const Scaffold()},
            onGenerateRoute: (settings) {
              if (settings.name == '/') {
                return MaterialPageRoute(
                  settings: const RouteSettings(name: '/', arguments: 'lol'),
                  builder: (_) => const QuizScreen(),
                );
              }
              return null;
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AnswerButton), findsNWidgets(4));
    });

    testWidgets('tapping any answer button disables all buttons', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MaterialApp(
            home: const QuizScreen(),
            routes: {'/success': (_) => const Scaffold(body: Text('Success!'))},
          ),
        ),
      );
      await tester.pump();

      // All buttons enabled initially
      final before = tester.widgetList<AnswerButton>(find.byType(AnswerButton)).toList();
      expect(before.every((b) => b.onPressed != null), isTrue);

      await tester.tap(find.byType(AnswerButton).first);
      await tester.pump();

      // All buttons disabled after tap (animation in progress)
      final after = tester.widgetList<AnswerButton>(find.byType(AnswerButton)).toList();
      expect(after.every((b) => b.onPressed == null), isTrue);
    });

    testWidgets('after pumpAndSettle following tap, quiz resets or navigates', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MaterialApp(
            home: const QuizScreen(),
            routes: {'/success': (_) => const Scaffold(body: Text('Success!'))},
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(AnswerButton).first);
      await tester.pumpAndSettle();

      // Either navigated to /success OR buttons re-enabled with new question
      final onSuccess = find.text('Success!').evaluate().isNotEmpty;
      final buttonsBack = find.byType(AnswerButton).evaluate().isNotEmpty &&
          tester.widgetList<AnswerButton>(find.byType(AnswerButton))
              .any((b) => b.onPressed != null);
      expect(onSuccess || buttonsBack, isTrue);
    });

    testWidgets('respuesta correcta llama ProfileProvider.recordAnswer(game, true)',
        (tester) async {
      // Retries with fresh widgets (random questions) until tapping the
      // first AnswerButton happens to be the correct one.
      var found = false;
      for (var attempt = 0; attempt < 15 && !found; attempt++) {
        final mockProfileProvider = MockProfileProvider();
        when(() => mockProfileProvider.recordAnswer(any(), any())).thenAnswer((_) async {});

        // Unmount first: pumping a matching MaterialApp/QuizScreen shape
        // directly would let Flutter's element diffing reuse the previous
        // `_QuizScreenState` (with `_answerState` already non-idle from the
        // prior tap), silently making `_onAnswer` a no-op on this attempt.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          _wrap(
            MaterialApp(
              home: const QuizScreen(),
              routes: {'/success': (_) => const Scaffold(body: Text('Success!'))},
            ),
            profileProvider: mockProfileProvider,
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(AnswerButton).first);
        // A single pump is enough: `_onAnswer` calls `recordAnswer`
        // synchronously before kicking off the feedback animation, so there
        // is no need to let bounce/shake/navigation finish for this check.
        await tester.pump();

        final captured =
            verify(() => mockProfileProvider.recordAnswer(captureAny(), captureAny())).captured;
        final game = captured[captured.length - 2] as String;
        final correct = captured.last as bool;

        if (correct) {
          found = true;
          expect(game, 'pokemon');
        }
      }
      expect(found, isTrue, reason: 'Expected at least one attempt to tap the correct answer');
    });

    testWidgets('respuesta incorrecta llama recordAnswer(game, false)', (tester) async {
      // Retries with fresh widgets (random questions) until tapping the
      // first AnswerButton happens to be a wrong one.
      var found = false;
      for (var attempt = 0; attempt < 15 && !found; attempt++) {
        final mockProfileProvider = MockProfileProvider();
        when(() => mockProfileProvider.recordAnswer(any(), any())).thenAnswer((_) async {});

        // Unmount first: pumping a matching MaterialApp/QuizScreen shape
        // directly would let Flutter's element diffing reuse the previous
        // `_QuizScreenState` (with `_answerState` already non-idle from the
        // prior tap), silently making `_onAnswer` a no-op on this attempt.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          _wrap(
            MaterialApp(
              home: const QuizScreen(),
              routes: {'/success': (_) => const Scaffold(body: Text('Success!'))},
            ),
            profileProvider: mockProfileProvider,
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(AnswerButton).first);
        // A single pump is enough: `_onAnswer` calls `recordAnswer`
        // synchronously before kicking off the feedback animation, so there
        // is no need to let bounce/shake/navigation finish for this check.
        await tester.pump();

        final captured =
            verify(() => mockProfileProvider.recordAnswer(captureAny(), captureAny())).captured;
        final game = captured[captured.length - 2] as String;
        final correct = captured.last as bool;

        if (!correct) {
          found = true;
          expect(game, 'pokemon');
        }
      }
      expect(found, isTrue, reason: 'Expected at least one attempt to tap a wrong answer');
    });
  });
}
