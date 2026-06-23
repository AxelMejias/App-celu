import 'dart:math';
import '../data/all_questions.dart';
import '../models/question.dart';

class QuizService {
  final _random = Random();
  String? _lastQuestionText;

  Question getRandomQuestion(String game) {
    final bank = _bankFor(game);
    if (bank.length == 1) {
      _lastQuestionText = bank[0].text;
      return bank[0];
    }
    final shuffled = List<Question>.from(bank)..shuffle(_random);
    final question = shuffled.firstWhere(
      (q) => q.text != _lastQuestionText,
      orElse: () => shuffled[0],
    );
    _lastQuestionText = question.text;
    return question;
  }

  List<Question> getRandomQuestions(String game, {int count = 5}) {
    final bank = _bankFor(game);
    final shuffled = List<Question>.from(bank)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  List<Question> _bankFor(String game) {
    final bank = questionsByGame[game];
    if (bank == null) throw ArgumentError('Unknown game: $game');
    return bank;
  }
}
