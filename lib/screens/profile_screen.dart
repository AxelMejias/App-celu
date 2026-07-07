import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_stats_view.dart';

/// Displays the authenticated user's identity and per-game quiz statistics,
/// plus a sign-out entry point. Talks only to `ProfileProvider`/`AuthProvider`
/// — no direct Firestore/Firebase access (see C-13 design D-4, D-6).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.appBar,
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: profile.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  ProfileStatsView(
                    username: profile.username,
                    email: profile.email,
                    stats: profile.stats,
                  ),
                  const SizedBox(height: 24),
                  _buildSignOutButton(context),
                ],
              ),
            ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final auth = context.read<AuthProvider>();
          final navigator = Navigator.of(context);
          await auth.signOut();
          // AuthGate (root) now shows LoginScreen — pop this route to reveal it.
          navigator.popUntil((route) => route.isFirst);
        },
        icon: const Icon(Icons.logout, color: Colors.white70),
        label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white70)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
