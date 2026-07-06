import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game_stats.dart';

/// Snapshot of the authenticated user's identity and per-game statistics,
/// read from the `users/{uid}` Firestore document (see C-13 design D-1).
class UserProfile {
  const UserProfile({
    required this.username,
    required this.email,
    required this.stats,
  });

  final String username;
  final String email;
  final Map<String, GameStats> stats;
}

/// Thin wrapper over `cloud_firestore` that reads the user's profile and
/// records quiz answers. Firestore is injectable so tests can run against
/// `fake_cloud_firestore` without a real project (see C-13 design D-7).
class ProfileService {
  ProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<UserProfile> loadProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data() ?? <String, dynamic>{};

    final rawStats = data['stats'] as Map<String, dynamic>?;
    final stats = <String, GameStats>{
      if (rawStats != null)
        for (final entry in rawStats.entries)
          entry.key: GameStats.fromMap(Map<String, dynamic>.from(entry.value as Map)),
    };

    return UserProfile(
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      stats: stats,
    );
  }

  /// Atomically updates the counters for [game] within a transaction, so the
  /// read-modify-write of `currentStreak`/`bestStreak` is consistent (see
  /// C-13 design D-2).
  Future<void> recordAnswer(String uid, String game, bool correct) async {
    final docRef = _firestore.collection('users').doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() ?? <String, dynamic>{};
      final rawStats = data['stats'] as Map<String, dynamic>?;
      final rawGameStats = rawStats?[game] as Map<String, dynamic>?;
      final previous = rawGameStats != null
          ? GameStats.fromMap(Map<String, dynamic>.from(rawGameStats))
          : GameStats.empty();

      final updated = _applyAnswer(previous, correct);

      // Dot-path update so only this game's sub-map is written — sibling
      // games under `stats` are left untouched (see C-13 design D-2).
      transaction.update(docRef, {'stats.$game': updated.toMap()});
    });
  }

  /// Pure computation of the next [GameStats] after recording one answer.
  /// Extracted so the streak logic is easy to reason about independently of
  /// the transaction plumbing.
  GameStats _applyAnswer(GameStats previous, bool correct) {
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
