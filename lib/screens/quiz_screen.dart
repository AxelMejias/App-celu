import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/quiz_service.dart';
import '../theme/app_theme.dart';
import '../theme/game_themes.dart';
import '../widgets/answer_button.dart';

enum _AnswerState { idle, correct, incorrect }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _service = QuizService();
  late String _game;
  late Question _currentQuestion;
  int? _tappedIndex;
  _AnswerState _answerState = _AnswerState.idle;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _game = ModalRoute.of(context)?.settings.arguments as String? ?? 'pokemon';
      _currentQuestion = _service.getRandomQuestion(_game);
      _initialized = true;
    }
  }

  void _onAnswer(int index) {
    if (_answerState != _AnswerState.idle) return;

    final correct = index == _currentQuestion.correctIndex;
    setState(() {
      _tappedIndex = index;
      _answerState = correct ? _AnswerState.correct : _AnswerState.incorrect;
    });

    if (correct) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) Navigator.pushNamed(context, '/success');
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _currentQuestion = _service.getRandomQuestion(_game);
            _tappedIndex = null;
            _answerState = _AnswerState.idle;
          });
        }
      });
    }
  }

  Color _buttonColor(int index) {
    if (_tappedIndex == index) {
      return _answerState == _AnswerState.correct ? Colors.green : Colors.red;
    }
    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final bool buttonsEnabled = _answerState == _AnswerState.idle;
    final gameColor = gameThemes[_game]?.primaryColor;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: gameColor?.withValues(alpha: 0.85) ?? AppTheme.appBar,
        automaticallyImplyLeading: false,
        title: const Text(
          'Quiz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                question.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ...List.generate(question.options.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AnswerButton(
                  text: question.options[i],
                  onPressed: buttonsEnabled ? () => _onAnswer(i) : null,
                  color: _buttonColor(i),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
