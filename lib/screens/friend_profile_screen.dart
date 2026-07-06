import 'package:flutter/material.dart';

import '../models/user_summary.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_stats_view.dart';

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
                ],
              ),
            ),
    );
  }
}
