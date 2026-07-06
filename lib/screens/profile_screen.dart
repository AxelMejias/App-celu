import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_stats.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../theme/game_themes.dart';

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
                  _buildHeader(profile),
                  const SizedBox(height: 24),
                  _buildTotals(profile.stats),
                  const SizedBox(height: 16),
                  ...gameThemes.values.map(
                    (theme) => _buildGameCard(theme, profile.stats[theme.id] ?? GameStats.empty()),
                  ),
                  const SizedBox(height: 24),
                  _buildSignOutButton(context),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(ProfileProvider profile) {
    final initial = profile.username.isNotEmpty ? profile.username[0].toUpperCase() : '?';
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.deepPurple,
          child: Text(
            initial,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotals(Map<String, GameStats> stats) {
    final totalAnswered = stats.values.fold<int>(0, (sum, s) => sum + s.answered);
    final totalCorrect = stats.values.fold<int>(0, (sum, s) => sum + s.correct);
    final totalIncorrect = stats.values.fold<int>(0, (sum, s) => sum + s.incorrect);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.appBar,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _totalStat('Respondidas', totalAnswered),
          _totalStat('Correctas', totalCorrect),
          _totalStat('Incorrectas', totalIncorrect),
        ],
      ),
    );
  }

  Widget _totalStat(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildGameCard(GameTheme theme, GameStats stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.appBar,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(theme.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                theme.displayName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text('Respondidas: ${stats.answered}', style: _statTextStyle),
              Text('Correctas: ${stats.correct}', style: _statTextStyle),
              Text('Incorrectas: ${stats.incorrect}', style: _statTextStyle),
              Text('Racha actual: ${stats.currentStreak}', style: _statTextStyle),
              Text('Mejor racha: ${stats.bestStreak}', style: _statTextStyle),
              Text('Precisión: ${(stats.accuracy * 100).toStringAsFixed(0)}%', style: _statTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  static const _statTextStyle = TextStyle(color: Colors.white70, fontSize: 12);

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.read<AuthProvider>().signOut(),
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
