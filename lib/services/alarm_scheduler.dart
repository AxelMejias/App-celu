import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alarm.dart';

// Set during App initialization so the notification tap callback can navigate.
GlobalKey<NavigatorState>? alarmNavigatorKey;

const _channelId = 'levelup_alarm_channel';
const _channelName = 'Alarma LevelUp';

/// Pure computation of the next fire time for a daily one-shot alarm at
/// [time]. Returns today at [time] if that instant is still ahead of [now],
/// otherwise tomorrow at [time]. Extracted so it can be unit-tested without
/// touching any platform channel.
DateTime nextFireTime(TimeOfDay time, {DateTime? now}) {
  final effectiveNow = now ?? DateTime.now();
  var scheduled = DateTime(
    effectiveNow.year, effectiveNow.month, effectiveNow.day,
    time.hour, time.minute,
  );
  if (!scheduled.isAfter(effectiveNow)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

// Runs in a background isolate — must be a top-level function.
@pragma('vm:entry-point')
Future<void> alarmCallback(int alarmId, Map<String, dynamic>? params) async {
  WidgetsFlutterBinding.ensureInitialized();
  final game = params?['game'] as String? ?? 'pokemon';

  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await plugin.initialize(const InitializationSettings(android: androidInit));

  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.max,
      ));

  final androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    importance: Importance.max,
    priority: Priority.max,
    fullScreenIntent: true,
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
    playSound: true,
    enableVibration: true,
  );

  await plugin.show(
    alarmId,
    '¡Es hora de despertar!',
    'Respondé la pregunta de $game para apagar la alarma.',
    NotificationDetails(android: androidDetails),
    payload: game,
  );
}

class AlarmScheduler {
  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    alarmNavigatorKey = navigatorKey;
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await plugin.initialize(
        const InitializationSettings(android: androidInit),
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
      await plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.max,
          ));
    } catch (_) {}
  }

  /// Requests the runtime permissions the alarm notification needs to be
  /// visible: `POST_NOTIFICATIONS` (required on Android 13+ or the OS
  /// silently drops the notification), plus best-effort exact-alarm and
  /// full-screen-intent access. Safe no-op off Android, on older APIs, or if
  /// the platform channel is unavailable (e.g. running in tests). Must only
  /// be called from the main isolate — never from [alarmCallback].
  static Future<void> requestPermissions() async {
    if (!Platform.isAndroid) return;
    final androidPlugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;
    try {
      await androidPlugin.requestNotificationsPermission();
    } catch (_) {}
    try {
      await androidPlugin.requestExactAlarmsPermission();
    } catch (_) {}
    try {
      await androidPlugin.requestFullScreenIntentPermission();
    } catch (_) {}
  }

  static void _onNotificationTap(NotificationResponse response) {
    final game = response.payload ?? 'pokemon';
    alarmNavigatorKey?.currentState
        ?.pushNamed('/alarm-ring', arguments: game);
  }

  static Future<void> scheduleAlarm(Alarm alarm) async {
    if (!Platform.isAndroid) return;
    try {
      final scheduled = nextFireTime(alarm.time, now: DateTime.now());
      await AndroidAlarmManager.oneShotAt(
        scheduled,
        alarmId(alarm.id),
        alarmCallback,
        wakeup: true,
        exact: true,
        rescheduleOnReboot: true,
        params: {'game': alarm.game, 'id': alarm.id},
      );
    } catch (_) {}
  }

  static Future<void> cancelAlarm(String id) async {
    if (!Platform.isAndroid) return;
    try {
      await AndroidAlarmManager.cancel(alarmId(id));
    } catch (_) {}
  }

  // Exposed for unit testing.
  static int alarmId(String id) => id.hashCode & 0x7FFFFFFF;
}
