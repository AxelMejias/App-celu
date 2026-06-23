import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/alarm.dart';

void main() {
  group('Alarm', () {
    test('new Alarm without id gets a non-empty UUID v4', () {
      final alarm = Alarm(time: const TimeOfDay(hour: 7, minute: 0), game: 'pokemon');

      expect(alarm.id, isNotEmpty);
      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(alarm.id, matches(uuidPattern));
    });

    test('round-trip fromJson(toJson()) preserves all fields', () {
      final original = Alarm(
        id: 'test-id-123',
        time: const TimeOfDay(hour: 8, minute: 30),
        game: 'lol',
        isActive: false,
      );

      final restored = Alarm.fromJson(original.toJson());

      expect(restored.id, equals(original.id));
      expect(restored.time.hour, equals(original.time.hour));
      expect(restored.time.minute, equals(original.time.minute));
      expect(restored.game, equals(original.game));
      expect(restored.isActive, equals(original.isActive));
    });

    test('fromJson with isActive false produces alarm.isActive == false', () {
      final json = {
        'id': 'abc',
        'time': {'hour': 6, 'minute': 0},
        'game': 'valorant',
        'isActive': false,
      };

      final alarm = Alarm.fromJson(json);

      expect(alarm.isActive, isFalse);
    });

    test('toJson includes time as map with hour and minute keys', () {
      final alarm = Alarm(
        id: 'x',
        time: const TimeOfDay(hour: 7, minute: 30),
        game: 'pokemon',
      );

      final json = alarm.toJson();
      final timeMap = json['time'] as Map;

      expect(timeMap['hour'], equals(7));
      expect(timeMap['minute'], equals(30));
    });
  });
}
