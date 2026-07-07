import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/services/alarm_scheduler.dart';

void main() {
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
