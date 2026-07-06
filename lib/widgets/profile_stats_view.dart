import 'package:flutter/material.dart';

import '../models/game_stats.dart';
import '../theme/app_theme.dart';
import '../theme/game_themes.dart';

/// Stateless rendering of a user's identity header, aggregated totals and
/// per-game stat cards. Extracted from `ProfileScreen` so it can be reused,
/// read-only, by `FriendProfileScreen` (see C-14 design D-9). No behavior
/// change versus the inline rendering it replaces.
class ProfileStatsView extends StatelessWidget {
  const ProfileStatsView({
    super.key,
    required this.username,
    required this.email,
    required this.stats,
    this.showEmail = true,
  });

  final String username;
  final String email;
  final Map<String, GameStats> stats;
  final bool showEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildTotals(),
        const SizedBox(height: 16),
        ...gameThemes.values.map(
          (theme) => _buildGameCard(theme, stats[theme.id] ?? GameStats.empty()),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
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
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showEmail) ...[
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotals() {
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

  Widget _buildGameCard(GameTheme theme, GameStats gameStats) {
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
              Text('Respondidas: ${gameStats.answered}', style: _statTextStyle),
              Text('Correctas: ${gameStats.correct}', style: _statTextStyle),
              Text('Incorrectas: ${gameStats.incorrect}', style: _statTextStyle),
              Text('Racha actual: ${gameStats.currentStreak}', style: _statTextStyle),
              Text('Mejor racha: ${gameStats.bestStreak}', style: _statTextStyle),
              Text('Precisión: ${(gameStats.accuracy * 100).toStringAsFixed(0)}%', style: _statTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  static const _statTextStyle = TextStyle(color: Colors.white70, fontSize: 12);
}
