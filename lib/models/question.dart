class Question {
  final String game;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String difficulty;

  const Question({
    required this.game,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
  });
}
