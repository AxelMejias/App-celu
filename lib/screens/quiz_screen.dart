import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/profile_provider.dart';
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

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final _service = QuizService();
  late String _game;
  late Question _currentQuestion;
  int? _tappedIndex;
  _AnswerState _answerState = _AnswerState.idle;
  bool _initialized = false;

  late AnimationController _bounceCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 50),
    ]).animate(_bounceCtrl);

    _bounceCtrl.addStatusListener(_onBounceStatus);
    _shakeCtrl.addStatusListener(_onShakeStatus);
  }

  void _onBounceStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      Navigator.pushNamed(context, '/success');
    }
  }

  void _onShakeStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {
        _currentQuestion = _service.getRandomQuestion(_game);
        _tappedIndex = null;
        _answerState = _AnswerState.idle;
      });
      _shakeCtrl.reset();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _game = ModalRoute.of(context)?.settings.arguments as String? ?? 'pokemon';
      _currentQuestion = _service.getRandomQuestion(_game);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onAnswer(int index) {
    if (_answerState != _AnswerState.idle) return;

    final correct = index == _currentQuestion.correctIndex;
    setState(() {
      _tappedIndex = index;
      _answerState = correct ? _AnswerState.correct : _AnswerState.incorrect;
    });

    // Fire-and-forget: reporting the result must never block or delay the
    // feedback animation. `ProfileProvider.recordAnswer` is a safe no-op
    // when there is no authenticated user (see C-13 design D-5).
    context.read<ProfileProvider>().recordAnswer(_game, correct);

    if (correct) {
      _bounceCtrl.forward(from: 0);
    } else {
      _shakeCtrl.forward(from: 0);
    }
  }

  Color _buttonColor(int index) {
    if (_tappedIndex == index) {
      return _answerState == _AnswerState.correct ? Colors.green : Colors.red;
    }
    return Colors.deepPurple;
  }

  Widget _buildAnswerButton(int i, bool buttonsEnabled) {
    Widget button = AnswerButton(
      text: _currentQuestion.options[i],
      onPressed: buttonsEnabled ? () => _onAnswer(i) : null,
      color: _buttonColor(i),
    );

    if (_answerState == _AnswerState.correct && i == _tappedIndex) {
      button = ScaleTransition(scale: _bounceAnim, child: button);
    } else if (_answerState == _AnswerState.incorrect && i == _tappedIndex) {
      button = AnimatedBuilder(
        animation: _shakeCtrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(sin(_shakeCtrl.value * pi * 4) * 8.0, 0),
          child: child,
        ),
        child: button,
      );
    }

    return Padding(padding: const EdgeInsets.only(bottom: 14), child: button);
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
              ...List.generate(
                question.options.length,
                (i) => _buildAnswerButton(i, buttonsEnabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
