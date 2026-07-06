import 'package:flutter/foundation.dart';

import '../models/game_stats.dart';
import '../services/profile_service.dart';

/// Exposes the authenticated user's profile (identity + per-game stats) to
/// the widget tree as a [ChangeNotifier]. Mirrors the injectable-dependency
/// pattern used by `AuthProvider`/`AuthService` (see C-13 design D-4).
class ProfileProvider extends ChangeNotifier {
  ProfileProvider({ProfileService? profileService, required this.uid})
      : _profileService = profileService ?? ProfileService();

  final ProfileService _profileService;

  /// The authenticated user's uid, or `null` when signed out. `recordAnswer`
  /// becomes a safe no-op in that case (see C-13 design D-5).
  final String? uid;

  String _username = '';
  String _email = '';
  Map<String, GameStats> _stats = {};
  bool _isLoading = false;
  String? _errorMessage;

  String get username => _username;
  String get email => _email;
  Map<String, GameStats> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    final currentUid = uid;
    if (currentUid == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final profile = await _profileService.loadProfile(currentUid);
      _username = profile.username;
      _email = profile.email;
      _stats = profile.stats;
    } catch (e) {
      _errorMessage = 'No se pudo cargar el perfil. Intentá de nuevo';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reports a quiz answer for [game]. Safe no-op when there is no
  /// authenticated user (e.g. offline/tests) — the `QuizScreen` calls this
  /// fire-and-forget without checking auth state itself (C-13 design D-5).
  Future<void> recordAnswer(String game, bool correct) async {
    final currentUid = uid;
    if (currentUid == null) return;

    try {
      await _profileService.recordAnswer(currentUid, game, correct);
      final previous = _stats[game] ?? GameStats.empty();
      _stats = {
        ..._stats,
        game: _applyOptimisticUpdate(previous, correct),
      };
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No se pudo registrar la respuesta';
      notifyListeners();
    }
  }

  GameStats _applyOptimisticUpdate(GameStats previous, bool correct) {
    if (correct) {
      final nextStreak = previous.currentStreak + 1;
      return GameStats(
        answered: previous.answered + 1,
        correct: previous.correct + 1,
        incorrect: previous.incorrect,
        currentStreak: nextStreak,
        bestStreak: nextStreak > previous.bestStreak ? nextStreak : previous.bestStreak,
      );
    }
    return GameStats(
      answered: previous.answered + 1,
      correct: previous.correct,
      incorrect: previous.incorrect + 1,
      currentStreak: 0,
      bestStreak: previous.bestStreak,
    );
  }
}
