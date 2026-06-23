import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alarm.dart';

// Set during App initialization so the notification tap callback can navigate.
GlobalKey<NavigatorState>? alarmNavigatorKey;

const _channelId = 'levelup_alarm_channel';
const _channelName = 'Alarma LevelUp';

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

  static void _onNotificationTap(NotificationResponse response) {
    final game = response.payload ?? 'pokemon';
    alarmNavigatorKey?.currentState
        ?.pushNamed('/alarm-ring', arguments: game);
  }

  static Future<void> scheduleAlarm(Alarm alarm) async {
    try {
      final now = DateTime.now();
      var scheduled = DateTime(
        now.year, now.month, now.day,
        alarm.time.hour, alarm.time.minute,
      );
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
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
    try {
      await AndroidAlarmManager.cancel(alarmId(id));
    } catch (_) {}
  }

  // Exposed for unit testing.
  static int alarmId(String id) => id.hashCode & 0x7FFFFFFF;
}
