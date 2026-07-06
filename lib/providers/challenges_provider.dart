import 'package:flutter/foundation.dart';

import '../models/challenge.dart';
import '../models/challenge_question.dart';
import '../models/user_summary.dart';
import '../services/challenge_service.dart';

/// Exposes the authenticated user's challenges (received/sent/history) and
/// the propose/respond actions to the widget tree as a [ChangeNotifier].
/// Mirrors the injectable-dependency / `uid`-scoped pattern used by
/// `FriendsProvider` (see C-15 design D-8).
class ChallengesProvider extends ChangeNotifier {
  ChallengesProvider({ChallengeService? challengeService, required this.uid})
      : _challengeService = challengeService ?? ChallengeService();

  final ChallengeService _challengeService;

  /// The authenticated user's uid, or `null` when signed out. Every
  /// mutating operation becomes a safe no-op in that case (see C-15 design
  /// D-8, mirrors C-13 design D-5 / C-14 design D-7).
  final String? uid;

  List<Challenge> _incoming = [];
  List<Challenge> _sent = [];
  List<Challenge> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Cached once via `ChallengeService.loadUsername` so `propose` can
  // denormalize it without coupling this provider to `ProfileProvider`
  // (see C-15 design D-8, mirrors C-14 design D-6).
  String? _cachedUsername;

  List<Challenge> get incoming => _incoming;
  List<Challenge> get sent => _sent;
  List<Challenge> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAll() async {
    final currentUid = uid;
    if (currentUid == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _incoming = await _challengeService.loadIncoming(currentUid);
      _sent = await _challengeService.loadSent(currentUid);
      _history = await _challengeService.loadHistory(currentUid);
    } catch (e) {
      _errorMessage = 'No se pudieron cargar los desafíos. Intentá de nuevo';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Builds a frozen question set for [game] (delegates to
  /// `ChallengeService.buildQuestionSet`); used by the UI to arm the
  /// proposer's round before playing (see C-15 design D-9).
  List<ChallengeQuestion> buildQuestionSet(String game) {
    return _challengeService.buildQuestionSet(game);
  }

  /// Creates a challenge against [opponent] for [game] with the proposer's
  /// already-played [fromScore] and frozen [questions] (see C-15 design
  /// D-3, D-9). No-op without an authenticated user.
  Future<void> propose({
    required UserSummary opponent,
    required String game,
    required List<ChallengeQuestion> questions,
    required int fromScore,
  }) async {
    final currentUid = uid;
    if (currentUid == null) return;

    try {
      final username = await _myUsername(currentUid);
      await _challengeService.createChallenge(
        fromUid: currentUid,
        fromUsername: username,
        opponent: opponent,
        game: game,
        fromScore: fromScore,
        questions: questions,
      );
      _sent = await _challengeService.loadSent(currentUid);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No se pudo enviar el desafío. Intentá de nuevo';
      notifyListeners();
    }
  }

  /// Submits the opponent's [score] on a pending [challenge]: resolves and
  /// closes it (see C-15 design D-5), then moves it from `incoming` to
  /// `history` in memory. No-op if [challenge] is already `completed`
  /// (guards against double-submit, see C-15 design D-5 risk).
  Future<void> submitScore(Challenge challenge, int score) async {
    if (challenge.status == 'completed') return;

    try {
      await _challengeService.submitOpponentScore(challenge: challenge, score: score);
      _incoming = _incoming.where((c) => c.challengeId != challenge.challengeId).toList();
      _history = [
        ...(_history.where((c) => c.challengeId != challenge.challengeId)),
        challenge.copyWith(toScore: score, status: 'completed'),
      ];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No se pudo enviar el resultado. Intentá de nuevo';
      notifyListeners();
    }
  }

  Future<String> _myUsername(String currentUid) async {
    return _cachedUsername ??= await _challengeService.loadUsername(currentUid);
  }
}
