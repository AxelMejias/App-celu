import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_alarm/providers/alarm_provider.dart';
import 'package:levelup_alarm/models/alarm.dart';
import 'package:levelup_alarm/screens/home_screen.dart';

Widget _buildScreen(AlarmProvider provider) {
  return ChangeNotifierProvider<AlarmProvider>.value(
    value: provider,
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeScreen — empty state', () {
    testWidgets('shows placeholder text when no alarms', (tester) async {
      final provider = AlarmProvider();
      await tester.pumpWidget(_buildScreen(provider));
      await tester.pump();
      expect(find.textContaining('No hay alarmas'), findsOneWidget);
    });

    testWidgets('"Probar flujo" button is gone', (tester) async {
      final provider = AlarmProvider();
      await tester.pumpWidget(_buildScreen(provider));
      await tester.pump();
      expect(find.text('Probar flujo'), findsNothing);
    });
  });

  group('HomeScreen — friends entry point', () {
    testWidgets('shows a friends icon in the AppBar', (tester) async {
      final provider = AlarmProvider();
      await tester.pumpWidget(_buildScreen(provider));
      await tester.pump();
      expect(find.byIcon(Icons.people), findsOneWidget);
    });
  });

  group('HomeScreen — alarm list', () {
    testWidgets('shows alarm tile with time and game when one alarm exists', (tester) async {
      final provider = AlarmProvider();
      final alarm = Alarm(
        time: const TimeOfDay(hour: 7, minute: 30),
        game: 'pokemon',
      );
      await provider.addAlarm(alarm);
      await tester.pumpWidget(_buildScreen(provider));
      await tester.pump();
      // Shows display name from gameThemes
      expect(find.text('Pokémon'), findsOneWidget);
    });

    testWidgets('shows game icon in tile for pokemon alarm', (tester) async {
      final provider = AlarmProvider();
      await provider.addAlarm(
        Alarm(time: const TimeOfDay(hour: 8, minute: 0), game: 'pokemon'),
      );
      await tester.pumpWidget(_buildScreen(provider));
      await tester.pump();
      expect(find.text('🔴'), findsOneWidget);
    });
  });
}
