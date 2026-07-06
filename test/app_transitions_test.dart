import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_alarm/app.dart';
import 'package:levelup_alarm/screens/create_alarm_screen.dart';
import 'package:levelup_alarm/screens/alarm_ring_screen.dart';

import 'helpers/fake_signed_in_auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('App transitions — route resolution', () {
    testWidgets('navigating to /create-alarm renders CreateAlarmScreen', (tester) async {
      await tester.pumpWidget(App(authProviderOverride: FakeSignedInAuthProvider()));
      await tester.pump();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.pushNamed('/create-alarm');
      await tester.pumpAndSettle();

      expect(find.byType(CreateAlarmScreen), findsOneWidget);
    });

    testWidgets('navigating to /alarm-ring renders AlarmRingScreen', (tester) async {
      await tester.pumpWidget(App(authProviderOverride: FakeSignedInAuthProvider()));
      await tester.pump();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.pushNamed('/alarm-ring');
      await tester.pumpAndSettle();

      expect(find.byType(AlarmRingScreen), findsOneWidget);
    });
  });
}
