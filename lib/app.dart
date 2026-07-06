import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/alarm_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/create_alarm_screen.dart';
import 'screens/select_game_screen.dart';
import 'screens/alarm_ring_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/success_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key, this.navigatorKey, this.authProviderOverride});

  final GlobalKey<NavigatorState>? navigatorKey;

  /// Test-only hook: lets widget tests inject a fake [AuthProvider] so they
  /// don't need a real Firebase connection just to render the app's root.
  final AuthProvider? authProviderOverride;

  static const String home = '/';
  static const String createAlarm = '/create-alarm';
  static const String selectGame = '/select-game';
  static const String alarmRing = '/alarm-ring';
  static const String quiz = '/quiz';
  static const String success = '/success';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';

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
      case login:
        page = const LoginScreen();
      case register:
        page = const RegisterScreen();
      case profile:
        page = const ProfileScreen();
      default:
        page = const AuthGate();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AlarmProvider>(create: (_) => AlarmProvider()),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProviderOverride ?? AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(uid: null),
          update: (_, auth, previous) {
            final uid = auth.currentUser?.uid;
            // Reuse the existing ProfileProvider unless the signed-in user
            // actually changed, so an in-flight `load()`/optimistic update
            // isn't discarded on every unrelated AuthProvider rebuild.
            if (previous != null && previous.uid == uid) return previous;
            return ProfileProvider(uid: uid);
          },
        ),
      ],
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
