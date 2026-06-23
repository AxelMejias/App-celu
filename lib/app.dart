import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/create_alarm_screen.dart';
import 'screens/select_game_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const String home = '/';
  static const String createAlarm = '/create-alarm';
  static const String selectGame = '/select-game';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      },
    );
  }
}
