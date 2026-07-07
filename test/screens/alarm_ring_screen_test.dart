import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/screens/alarm_ring_screen.dart';
import 'package:levelup_alarm/services/alarm_sound_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAlarmSoundService extends Mock implements AlarmSoundService {}

void main() {
  late MockAlarmSoundService mockAlarmSound;

  setUp(() {
    mockAlarmSound = MockAlarmSoundService();
    when(() => mockAlarmSound.startRinging()).thenAnswer((_) async {});
    when(() => mockAlarmSound.stopRinging()).thenAnswer((_) async {});
    alarmSound = mockAlarmSound;
  });

  tearDown(() {
    alarmSound = NoopAlarmSoundService();
  });

  group('AlarmRingScreen', () {
    testWidgets('pushing the screen starts the alarm ringing exactly once', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AlarmRingScreen()),
      );
      await tester.pump();

      verify(() => mockAlarmSound.startRinging()).called(1);
    });

    testWidgets('renders without error and "Responder pregunta" navigates to /quiz',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AlarmRingScreen(),
          routes: {'/quiz': (_) => const Scaffold(body: Text('Quiz!'))},
        ),
      );
      await tester.pump();

      expect(find.text('Responder pregunta'), findsOneWidget);

      await tester.tap(find.text('Responder pregunta'));
      await tester.pumpAndSettle();

      expect(find.text('Quiz!'), findsOneWidget);
    });

    testWidgets('blocks system back navigation (canPop is false)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AlarmRingScreen()),
      );
      await tester.pump();

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);

      // A back navigation attempt must not remove the screen.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(AlarmRingScreen), findsOneWidget);
    });
  });
}
