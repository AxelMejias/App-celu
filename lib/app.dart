import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/alarm_provider.dart';
import 'screens/home_screen.dart';
import 'screens/create_alarm_screen.dart';
import 'screens/select_game_screen.dart';
import 'screens/alarm_ring_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/success_screen.dart';

class App extends StatelessWidget {
  const App({super.key, this.navigatorKey});

  final GlobalKey<NavigatorState>? navigatorKey;

  static const String home = '/';
  static const String createAlarm = '/create-alarm';
  static const String selectGame = '/select-game';
  static const String alarmRing = '/alarm-ring';
  static const String quiz = '/quiz';
  static const String success = '/success';

  static Route<dynamic> _buildRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case createAlarm:
        page = const CreateAlarmScreen();
      case selectGame:
        page = const SelectGameScreen();
      case alarmRing:
        page = const AlarmRingScreen();
      case quiz:
        page = const QuizScreen();
      case success:
        page = const SuccessScreen();
      default:
        page = const HomeScreen();
    }
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, animation, _, child) {
        final fadeTween = CurveTween(curve: Curves.easeInOut);
        final slideTween = Tween(
          begin: const Offset(0.04, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlarmProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'LevelUp Alarm',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.deepPurple,
          scaffoldBackgroundColor: AppTheme.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppTheme.appBar,
          ),
        ),
        initialRoute: home,
        onGenerateRoute: _buildRoute,
      ),
    );
  }
}
