import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_summary.dart';
import '../providers/challenges_provider.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../theme/game_themes.dart';
import '../widgets/profile_stats_view.dart';
import 'challenge_play_screen.dart';

/// Read-only view of a friend's identity and per-game statistics, reusing
/// `ProfileStatsView` (see C-14 design D-9). Offers no sign-out or
/// answer-recording actions — it is a passive view of someone else's data.
class FriendProfileScreen extends StatefulWidget {
  const FriendProfileScreen({super.key, required this.friend, this.profileService});

  final UserSummary friend;

  /// Test-only hook: lets widget tests inject a fake [ProfileService] so
  /// they don't need a real Firebase connection (mirrors
  /// `App.authProviderOverride`).
  final ProfileService? profileService;

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  late final ProfileService _profileService = widget.profileService ?? ProfileService();

  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final profile = await _profileService.loadProfile(widget.friend.uid);
    if (mounted) setState(() => _profile = profile);
  }

  Future<void> _pickGameAndChallenge() async {
    final game = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.appBar,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: gameThemes.values
              .map(
                (theme) => ListTile(
                  leading: Text(theme.icon, style: const TextStyle(fontSize: 20)),
                  title: Text(theme.displayName, style: const TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, theme.id),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (game == null || !mounted) return;

    final questions = context.read<ChallengesProvider>().buildQuestionSet(game);
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/challenge-play',
      arguments: ChallengePlayArgs.propose(opponent: widget.friend, game: game, questions: questions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.appBar,
        title: Text(
          widget.friend.username,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  ProfileStatsView(
                    username: profile.username,
                    email: profile.email,
                    stats: profile.stats,
                    showEmail: false,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _pickGameAndChallenge,
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('Desafiar'),
                  ),
                ],
              ),
            ),
    );
  }
}
