import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_alarm/providers/alarm_provider.dart';
import 'package:levelup_alarm/models/alarm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AlarmProvider — initial state', () {
    test('alarms is empty on creation', () {
      final provider = AlarmProvider();
      expect(provider.alarms, isEmpty);
    });
  });

  group('AlarmProvider — addAlarm', () {
    test('adds alarm and exposes it in alarms list', () async {
      final provider = AlarmProvider();
      final alarm = Alarm(
        time: const TimeOfDay(hour: 7, minute: 30),
        game: 'pokemon',
      );
      await provider.addAlarm(alarm);
      expect(provider.alarms.length, 1);
      expect(provider.alarms[0].id, alarm.id);
    });
  });

  group('AlarmProvider — deleteAlarm', () {
    test('removes alarm from list', () async {
      final provider = AlarmProvider();
      final alarm = Alarm(time: const TimeOfDay(hour: 8, minute: 0), game: 'lol');
      await provider.addAlarm(alarm);
      await provider.deleteAlarm(alarm.id);
      expect(provider.alarms, isEmpty);
    });
  });

  group('AlarmProvider — toggleAlarm', () {
    test('active alarm becomes inactive', () async {
      final provider = AlarmProvider();
      final alarm = Alarm(
        time: const TimeOfDay(hour: 7, minute: 0),
        game: 'valorant',
        isActive: true,
      );
      await provider.addAlarm(alarm);
      await provider.toggleAlarm(alarm.id);
      expect(provider.alarms[0].isActive, isFalse);
    });

    test('inactive alarm becomes active', () async {
      final provider = AlarmProvider();
      final alarm = Alarm(
        time: const TimeOfDay(hour: 7, minute: 0),
        game: 'warframe',
        isActive: false,
      );
      await provider.addAlarm(alarm);
      await provider.toggleAlarm(alarm.id);
      expect(provider.alarms[0].isActive, isTrue);
    });
  });

  group('AlarmProvider — notifyListeners', () {
    test('notifies listeners after addAlarm', () async {
      final provider = AlarmProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      await provider.addAlarm(
        Alarm(time: const TimeOfDay(hour: 6, minute: 0), game: 'pokemon'),
      );
      expect(notifyCount, greaterThanOrEqualTo(1));
    });
  });

  group('AlarmProvider — updateAlarm', () {
    test('updates the alarm in place, keeping the same id', () async {
      final provider = AlarmProvider();
      final alarm = Alarm(
        id: 'X',
        time: const TimeOfDay(hour: 7, minute: 30),
        game: 'pokemon',
      );
      await provider.addAlarm(alarm);
      await provider.updateAlarm(
        Alarm(id: 'X', time: const TimeOfDay(hour: 8, minute: 0), game: 'lol'),
      );
      expect(provider.alarms.length, 1);
      expect(provider.alarms[0].id, 'X');
      expect(provider.alarms[0].time.hour, 8);
      expect(provider.alarms[0].game, 'lol');
    });

    test('notifies listeners after updateAlarm', () async {
      final provider = AlarmProvider();
      final alarm = Alarm(
        id: 'Y',
        time: const TimeOfDay(hour: 7, minute: 0),
        game: 'pokemon',
      );
      await provider.addAlarm(alarm);
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      await provider.updateAlarm(
        Alarm(id: 'Y', time: const TimeOfDay(hour: 9, minute: 0), game: 'lol'),
      );
      expect(notifyCount, greaterThanOrEqualTo(1));
    });
  });
}
