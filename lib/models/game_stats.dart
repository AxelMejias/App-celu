/// Immutable per-game quiz counters, persisted as a nested map under
/// `users/{uid}.stats.{game}` in Firestore (see C-13 design D-1).
class GameStats {
  const GameStats({
    required this.answered,
    required this.correct,
    required this.incorrect,
    required this.currentStreak,
    required this.bestStreak,
  });

  /// All counters at zero — used for games with no recorded answers yet.
  factory GameStats.empty() => const GameStats(
        answered: 0,
        correct: 0,
        incorrect: 0,
        currentStreak: 0,
        bestStreak: 0,
      );

  factory GameStats.fromMap(Map<String, dynamic> map) => GameStats(
        answered: (map['answered'] as num?)?.toInt() ?? 0,
        correct: (map['correct'] as num?)?.toInt() ?? 0,
        incorrect: (map['incorrect'] as num?)?.toInt() ?? 0,
        currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
        bestStreak: (map['bestStreak'] as num?)?.toInt() ?? 0,
      );

  final int answered;
  final int correct;
  final int incorrect;
  final int currentStreak;
  final int bestStreak;

  /// Fraction of correct answers over answered; 0 (not NaN) when nothing
  /// has been answered yet.
  double get accuracy => answered == 0 ? 0 : correct / answered;

  /// Alias for [answered], used by the profile UI for aggregated totals.
  int get total => answered;

  Map<String, dynamic> toMap() => {
        'answered': answered,
        'correct': correct,
        'incorrect': incorrect,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStats &&
          runtimeType == other.runtimeType &&
          answered == other.answered &&
          correct == other.correct &&
          incorrect == other.incorrect &&
          currentStreak == other.currentStreak &&
          bestStreak == other.bestStreak;

  @override
  int get hashCode => Object.hash(answered, correct, incorrect, currentStreak, bestStreak);
}
