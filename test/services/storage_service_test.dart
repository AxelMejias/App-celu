import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_alarm/models/alarm.dart';
import 'package:levelup_alarm/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  late StorageService svc;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    svc = StorageService();
  });

  group('StorageService — loadAlarms', () {
    test('returns [] when storage is empty', () async {
      final result = await svc.loadAlarms();
      expect(result, isEmpty);
    });
  });

  group('StorageService — saveAlarms / loadAlarms round-trip', () {
    test('saves and reloads one alarm correctly', () async {
      final alarm = Alarm(
        time: const TimeOfDay(hour: 7, minute: 30),
        game: 'pokemon',
        isActive: true,
      );
      await svc.saveAlarms([alarm]);
      final loaded = await svc.loadAlarms();
      expect(loaded.length, 1);
      expect(loaded[0].id, alarm.id);
      expect(loaded[0].time.hour, 7);
      expect(loaded[0].time.minute, 30);
      expect(loaded[0].game, 'pokemon');
      expect(loaded[0].isActive, true);
    });
  });

  group('StorageService — addAlarm', () {
    test('adds to empty store', () async {
      final alarm = Alarm(time: const TimeOfDay(hour: 8, minute: 0), game: 'lol');
      await svc.addAlarm(alarm);
      final loaded = await svc.loadAlarms();
      expect(loaded.length, 1);
      expect(loaded[0].id, alarm.id);
      expect(loaded[0].game, 'lol');
    });

    test('appends to existing store', () async {
      final a1 = Alarm(time: const TimeOfDay(hour: 6, minute: 0), game: 'pokemon');
      final a2 = Alarm(time: const TimeOfDay(hour: 9, minute: 0), game: 'valorant');
      await svc.addAlarm(a1);
      await svc.addAlarm(a2);
      final loaded = await svc.loadAlarms();
      expect(loaded.length, 2);
    });
  });

  group('StorageService — deleteAlarm', () {
    test('deletes the only alarm', () async {
      final alarm = Alarm(time: const TimeOfDay(hour: 7, minute: 0), game: 'terraria');
      await svc.addAlarm(alarm);
      await svc.deleteAlarm(alarm.id);
      final loaded = await svc.loadAlarms();
      expect(loaded, isEmpty);
    });

    test('deletes one alarm and leaves the other', () async {
      final a1 = Alarm(time: const TimeOfDay(hour: 7, minute: 0), game: 'pokemon');
      final a2 = Alarm(time: const TimeOfDay(hour: 8, minute: 0), game: 'lol');
      await svc.addAlarm(a1);
      await svc.addAlarm(a2);
      await svc.deleteAlarm(a1.id);
      final loaded = await svc.loadAlarms();
      expect(loaded.length, 1);
      expect(loaded.any((a) => a.id == a1.id), isFalse);
    });
  });

  group('StorageService — toggleAlarm', () {
    test('active alarm becomes inactive', () async {
      final alarm = Alarm(
        time: const TimeOfDay(hour: 7, minute: 0),
        game: 'overwatch',
        isActive: true,
      );
      await svc.addAlarm(alarm);
      await svc.toggleAlarm(alarm.id);
      final loaded = await svc.loadAlarms();
      expect(loaded[0].isActive, isFalse);
    });

    test('inactive alarm becomes active', () async {
      final alarm = Alarm(
        time: const TimeOfDay(hour: 7, minute: 0),
        game: 'warframe',
        isActive: false,
      );
      await svc.addAlarm(alarm);
      await svc.toggleAlarm(alarm.id);
      final loaded = await svc.loadAlarms();
      expect(loaded[0].isActive, isTrue);
    });
  });

  group('StorageService — updateAlarm', () {
    test('replaces the alarm by id, preserving list order', () async {
      final a = Alarm(time: const TimeOfDay(hour: 7, minute: 0), game: 'pokemon');
      final b = Alarm(time: const TimeOfDay(hour: 8, minute: 0), game: 'lol');
      await svc.addAlarm(a);
      await svc.addAlarm(b);
      final updatedB = Alarm(
        id: b.id,
        time: const TimeOfDay(hour: 9, minute: 15),
        game: 'valorant',
      );
      await svc.updateAlarm(updatedB);
      final loaded = await svc.loadAlarms();
      expect(loaded.length, 2);
      expect(loaded[0].id, a.id);
      expect(loaded[1].id, b.id);
      expect(loaded[1].time.hour, 9);
      expect(loaded[1].time.minute, 15);
      expect(loaded[1].game, 'valorant');
    });

    test('non-existent id leaves the list unchanged', () async {
      final a = Alarm(time: const TimeOfDay(hour: 7, minute: 0), game: 'pokemon');
      await svc.addAlarm(a);
      final ghost = Alarm(
        id: 'does-not-exist',
        time: const TimeOfDay(hour: 10, minute: 0),
        game: 'lol',
      );
      await svc.updateAlarm(ghost);
      final loaded = await svc.loadAlarms();
      expect(loaded.length, 1);
      expect(loaded[0].id, a.id);
      expect(loaded[0].game, 'pokemon');
    });
  });
}
