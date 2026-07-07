import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/screens/success_screen.dart';
import 'package:levelup_alarm/services/alarm_sound_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAlarmSoundService extends Mock implements AlarmSoundService {}

void main() {
  group('SuccessScreen', () {
    testWidgets('renders success message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/success',
          routes: {
            '/': (_) => const Scaffold(body: Text('Home')),
            '/success': (_) => const SuccessScreen(),
          },
        ),
      );

      expect(find.text('¡Correcto!'), findsOneWidget);

      // Advance past the 3-second auto-navigation timer
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // After navigation, SuccessScreen is gone
      expect(find.text('¡Correcto!'), findsNothing);
    });

    testWidgets('content is visible after entry animation completes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/success',
          routes: {
            '/': (_) => const Scaffold(body: Text('Home')),
            '/success': (_) => const SuccessScreen(),
          },
        ),
      );

      // Let entry animation complete (500ms)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('¡Correcto!'), findsOneWidget);
      expect(find.text('Alarma desactivada.\nVolviendo al inicio...'), findsOneWidget);

      // Clear the pending 3-second auto-navigation timer
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });

  group('SuccessScreen — alarm sound', () {
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

    testWidgets('rendering the screen stops the alarm ringing exactly once', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/success',
          routes: {
            '/': (_) => const Scaffold(body: Text('Home')),
            '/success': (_) => const SuccessScreen(),
          },
        ),
      );
      await tester.pump();

      verify(() => mockAlarmSound.stopRinging()).called(1);

      // Clear the pending 3-second auto-navigation timer.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });
}
