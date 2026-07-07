import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_alarm/providers/alarm_provider.dart';
import 'package:levelup_alarm/models/alarm.dart';
import 'package:levelup_alarm/screens/create_alarm_screen.dart';

Widget _buildScreen(AlarmProvider provider, {Alarm? existing}) {
  return ChangeNotifierProvider<AlarmProvider>.value(
    value: provider,
    child: MaterialApp(home: CreateAlarmScreen(existing: existing)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CreateAlarmScreen — edit mode', () {
    testWidgets('pre-fills time and game, and Save is enabled', (tester) async {
      final provider = AlarmProvider();
      final existing = Alarm(
        time: const TimeOfDay(hour: 7, minute: 30),
        game: 'pokemon',
      );
      await tester.pumpWidget(_buildScreen(provider, existing: existing));
      await tester.pump();

      expect(find.textContaining('Pokémon'), findsOneWidget);
      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Guardar'),
      );
      expect(saveButton.onPressed, isNotNull);
      expect(find.text('Editar Alarma'), findsOneWidget);
    });
  });

  group('CreateAlarmScreen — create mode (no existing alarm)', () {
    testWidgets('shows "Nueva Alarma" title and Save disabled until a game is picked',
        (tester) async {
      final provider = AlarmProvider();
      await tester.pumpWidget(_buildScreen(provider));
      await tester.pump();

      expect(find.text('Nueva Alarma'), findsOneWidget);
      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Guardar'),
      );
      expect(saveButton.onPressed, isNull);
    });
  });
}
