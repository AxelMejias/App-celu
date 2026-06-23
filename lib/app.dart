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
  const App({super.key});

  static const String home = '/';
  static const String createAlarm = '/create-alarm';
  static const String selectGame = '/select-game';
  static const String alarmRing = '/alarm-ring';
  static const String quiz = '/quiz';
  static const String success = '/success';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlarmProvider(),
      child: MaterialApp(
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
        routes: {
          home: (context) => const HomeScreen(),
          createAlarm: (context) => const CreateAlarmScreen(),
          selectGame: (context) => const SelectGameScreen(),
          alarmRing: (context) => const AlarmRingScreen(),
          quiz: (context) => const QuizScreen(),
          success: (context) => const SuccessScreen(),
        },
      ),
    );
  }
}
