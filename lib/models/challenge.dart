import 'challenge_question.dart';

/// Result of comparing both players' scores in a challenge (see C-15 design
/// D-5, D-6): a pure function so it is trivial to test in isolation.
class WinnerResolution {
  const WinnerResolution({required this.winnerUid, required this.isDraw});

  final String? winnerUid;
  final bool isDraw;
}

/// Compares [fromScore] (proposer) with [toScore] (opponent): whoever has
/// more correct answers wins; equal scores are a draw (`winnerUid` null,
/// `isDraw` true). Pure — no Firestore, no side effects (see C-15 design
/// D-5, D-6).
WinnerResolution resolveWinner({
  required int fromScore,
  required int toScore,
  required String fromUid,
  required String toUid,
}) {
  if (fromScore > toScore) return WinnerResolution(winnerUid: fromUid, isDraw: false);
  if (toScore > fromScore) return WinnerResolution(winnerUid: toUid, isDraw: false);
  return const WinnerResolution(winnerUid: null, isDraw: true);
}

/// An asynchronous trivia duel between two friends: `challenges/{autoId}`
/// with the question set frozen inside the document (see C-15 design D-1,
/// D-2).
class Challenge {
  const Challenge({
    required this.challengeId,
    required this.game,
    required this.fromUid,
    required this.fromUsername,
    required this.toUid,
    required this.toUsername,
    required this.questions,
    required this.fromScore,
    this.toScore,
    required this.status,
    this.winnerUid,
    this.isDraw = false,
    this.createdAt,
    this.completedAt,
  });

  factory Challenge.fromMap(Map<String, dynamic> map, {String? id}) => Challenge(
        challengeId: id ?? map['challengeId'] as String? ?? '',
        game: map['game'] as String? ?? '',
        fromUid: map['fromUid'] as String? ?? '',
        fromUsername: map['fromUsername'] as String? ?? '',
        toUid: map['toUid'] as String? ?? '',
        toUsername: map['toUsername'] as String? ?? '',
        questions: (map['questions'] as List<dynamic>?)
                ?.map((q) => ChallengeQuestion.fromMap(q as Map<String, dynamic>))
                .toList() ??
            const [],
        fromScore: (map['fromScore'] as num?)?.toInt() ?? 0,
        toScore: (map['toScore'] as num?)?.toInt(),
        status: map['status'] as String? ?? 'pending',
        winnerUid: map['winnerUid'] as String?,
        isDraw: map['isDraw'] as bool? ?? false,
        createdAt: _toDateTime(map['createdAt']),
        completedAt: _toDateTime(map['completedAt']),
      );

  final String challengeId;
  final String game;
  final String fromUid;
  final String fromUsername;
  final String toUid;
  final String toUsername;
  final List<ChallengeQuestion> questions;
  final int fromScore;
  final int? toScore;
  final String status;
  final String? winnerUid;
  final bool isDraw;
  final DateTime? createdAt;
  final DateTime? completedAt;

  Map<String, dynamic> toMap() => {
        'challengeId': challengeId,
        'game': game,
        'fromUid': fromUid,
        'fromUsername': fromUsername,
        'toUid': toUid,
        'toUsername': toUsername,
        'questions': questions.map((q) => q.toMap()).toList(),
        'fromScore': fromScore,
        'toScore': toScore,
        'status': status,
        'winnerUid': winnerUid,
        'isDraw': isDraw,
        'createdAt': createdAt,
        'completedAt': completedAt,
      };

  Challenge copyWith({
    int? toScore,
    String? status,
    String? winnerUid,
    bool? isDraw,
    DateTime? completedAt,
  }) =>
      Challenge(
        challengeId: challengeId,
        game: game,
        fromUid: fromUid,
        fromUsername: fromUsername,
        toUid: toUid,
        toUsername: toUsername,
        questions: questions,
        fromScore: fromScore,
        toScore: toScore ?? this.toScore,
        status: status ?? this.status,
        winnerUid: winnerUid ?? this.winnerUid,
        isDraw: isDraw ?? this.isDraw,
        createdAt: createdAt,
        completedAt: completedAt ?? this.completedAt,
      );

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    // Firestore Timestamp exposes toDate(); avoid a direct cloud_firestore
    // import in the model so it stays a plain, easily-testable Dart class.
    final dynamic dyn = value;
    try {
      return dyn.toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
