import 'question.dart';

/// Immutable snapshot of a quiz [Question], embedded inside a `Challenge`
/// document so both players answer exactly the same set even if the local
/// question bank changes later (see C-15 design D-1, D-4).
class ChallengeQuestion {
  const ChallengeQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  /// Copies `text`/`options`/`correctIndex` from a quiz [Question],
  /// discarding domain fields (`game`, `difficulty`) that don't matter once
  /// the question is frozen inside a challenge (see C-15 design D-4).
  factory ChallengeQuestion.fromQuestion(Question question) => ChallengeQuestion(
        text: question.text,
        options: question.options,
        correctIndex: question.correctIndex,
      );

  factory ChallengeQuestion.fromMap(Map<String, dynamic> map) => ChallengeQuestion(
        text: map['text'] as String? ?? '',
        options: (map['options'] as List<dynamic>?)?.cast<String>() ?? const [],
        correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
      );

  final String text;
  final List<String> options;
  final int correctIndex;

  Map<String, dynamic> toMap() => {
        'text': text,
        'options': options,
        'correctIndex': correctIndex,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeQuestion &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          correctIndex == other.correctIndex &&
          _listEquals(options, other.options);

  @override
  int get hashCode => Object.hash(text, correctIndex, Object.hashAll(options));

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
