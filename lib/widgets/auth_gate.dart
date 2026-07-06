import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../theme/app_theme.dart';

/// Root routing widget: watches [AuthProvider] and decides whether the app
/// shows [LoginScreen] or [HomeScreen], reacting live to sign-in/out.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.currentUser != null) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
