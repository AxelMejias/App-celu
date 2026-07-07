import 'dart:ui' show IsolateNameServer;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/screens/alarm_ring_screen.dart';
import 'package:levelup_alarm/services/alarm_scheduler.dart';
import 'package:levelup_alarm/services/alarm_sound_service.dart';

/// Doble con estado de ringing configurable para simular "la alarma ya está
/// superpuesta" sin tocar plugins.
class _FakeSoundService implements AlarmSoundService {
  _FakeSoundService({this.ringing = false});

  bool ringing;

  @override
  Future<void> startRinging() async {
    ringing = true;
  }

  @override
  Future<void> stopRinging() async {
    ringing = false;
  }

  @override
  bool get isRinging => ringing;
}

Future<void> _pumpHost(WidgetTester tester, GlobalKey<NavigatorState> navKey) async {
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navKey,
      home: const Scaffold(body: Text('HOME')),
      routes: {'/alarm-ring': (_) => const AlarmRingScreen()},
    ),
  );
}

void main() {
  tearDown(() {
    alarmSound = NoopAlarmSoundService();
  });

  testWidgets(
      'un mensaje del puerto del alarm isolate superpone AlarmRingScreen '
      '(app en primer plano, sin tocar la notificación)', (tester) async {
    alarmSound = _FakeSoundService();
    final navKey = GlobalKey<NavigatorState>();
    await _pumpHost(tester, navKey);
    await AlarmScheduler.initialize(navKey);

    final port = IsolateNameServer.lookupPortByName(alarmRingPortName);
    expect(port, isNotNull, reason: 'initialize debe registrar el puerto');

    await tester.runAsync(() async {
      port!.send('pokemon');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.byType(AlarmRingScreen), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('si ya está sonando, el mensaje del puerto NO apila otra pantalla',
      (tester) async {
    alarmSound = _FakeSoundService(ringing: true);
    final navKey = GlobalKey<NavigatorState>();
    await _pumpHost(tester, navKey);
    await AlarmScheduler.initialize(navKey);

    await tester.runAsync(() async {
      IsolateNameServer.lookupPortByName(alarmRingPortName)!.send('pokemon');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.byType(AlarmRingScreen), findsNothing);
    expect(find.text('HOME'), findsOneWidget);
  });
}
