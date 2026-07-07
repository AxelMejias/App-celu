import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/services/alarm_scheduler.dart';
import 'package:levelup_alarm/models/alarm.dart';

void main() {
  group('buildAlarmParams', () {
    test('includes game, id, hour and minute', () {
      final alarm = Alarm(
        id: 'a1',
        time: const TimeOfDay(hour: 7, minute: 30),
        game: 'pokemon',
      );
      final params = buildAlarmParams(alarm);
      expect(params['game'], 'pokemon');
      expect(params['id'], 'a1');
      expect(params['hour'], 7);
      expect(params['minute'], 30);
    });
  });

  group('timeFromParams', () {
    test('reconstructs TimeOfDay from hour and minute', () {
      final result = timeFromParams(
        const {'game': 'lol', 'id': 'a1', 'hour': 6, 'minute': 5},
      );
      expect(result, const TimeOfDay(hour: 6, minute: 5));
    });

    test('reconstructs a different hour/minute pair (not hardcoded)', () {
      final result = timeFromParams(
        const {'game': 'pokemon', 'id': 'a2', 'hour': 21, 'minute': 45},
      );
      expect(result, const TimeOfDay(hour: 21, minute: 45));
    });

    test('returns null when hour/minute are missing (old-code payload)', () {
      final result = timeFromParams(const {'game': 'lol', 'id': 'a1'});
      expect(result, isNull);
    });

    test('returns null when params themselves are null', () {
      final result = timeFromParams(null);
      expect(result, isNull);
    });
  });

  group('nextFireTime', () {
    test('time already passed today — schedules for tomorrow', () {
      final now = DateTime(2026, 7, 7, 10, 0);
      final result = nextFireTime(const TimeOfDay(hour: 7, minute: 30), now: now);
      expect(result, DateTime(2026, 7, 8, 7, 30));
    });

    test('time not yet reached today — schedules for today', () {
      final now = DateTime(2026, 7, 7, 6, 0);
      final result = nextFireTime(const TimeOfDay(hour: 7, minute: 30), now: now);
      expect(result, DateTime(2026, 7, 7, 7, 30));
    });

    test('time exactly equal to now — schedules for tomorrow', () {
      final now = DateTime(2026, 7, 7, 7, 30);
      final result = nextFireTime(const TimeOfDay(hour: 7, minute: 30), now: now);
      expect(result, DateTime(2026, 7, 8, 7, 30));
    });
  });
}
