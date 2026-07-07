import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/alarm_scheduler.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // Firebase not configured yet (placeholder firebase_options.dart, or
    // running in CI without google-services.json). The app still boots;
    // AuthGate/AuthProvider will simply behave as if there is no session.
  }

  try {
    await AndroidAlarmManager.initialize();
  } catch (_) {}

  await AlarmScheduler.initialize(navigatorKey);
  await AlarmScheduler.requestPermissions();

  // Handle notification that launched the app while it was closed.
  String? launchGame;
  try {
    final plugin = FlutterLocalNotificationsPlugin();
    final launchDetails = await plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      launchGame = launchDetails!.notificationResponse?.payload ?? 'pokemon';
    }
  } catch (_) {}

  runApp(App(navigatorKey: navigatorKey));

  if (launchGame != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState
          ?.pushNamed('/alarm-ring', arguments: launchGame);
    });
  }
}
