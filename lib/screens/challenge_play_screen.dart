import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/challenge.dart';
import '../models/challenge_question.dart';
import '../models/user_summary.dart';
import '../providers/challenges_provider.dart';
import '../theme/app_theme.dart';
import '../theme/game_themes.dart';
import '../widgets/answer_button.dart';

/// Whether the player is proposing a new challenge (playing their own round
/// before it is sent) or responding to one already received (see C-15
/// design D-9).
enum ChallengePlayMode { propose, respond }

/// Arguments for `ChallengePlayScreen`, passed via `RouteSettings.arguments`
/// (see C-15 design D-9, D-10). Both modes reduce to "answer N embedded
/// questions and count the hits" — only the source of the questions and
/// what happens with the final score differ.
class ChallengePlayArgs {
  ChallengePlayArgs._({
    required this.mode,
    this.opponent,
    required this.game,
    required this.questions,
    this.challenge,
  });

  factory ChallengePlayArgs.propose({
    required UserSummary opponent,
    required String game,
    required List<ChallengeQuestion> questions,
  }) =>
      ChallengePlayArgs._(
        mode: ChallengePlayMode.propose,
        opponent: opponent,
        game: game,
        questions: questions,
      );

  factory ChallengePlayArgs.respond(Challenge challenge) => ChallengePlayArgs._(
        mode: ChallengePlayMode.respond,
        game: challenge.game,
        questions: challenge.questions,
        challenge: challenge,
      );

  final ChallengePlayMode mode;
  final UserSummary? opponent;
  final String game;
  final List<ChallengeQuestion> questions;
  final Challenge? challenge;
}

/// Plays a single challenge round (proposer's or opponent's): presents the
/// frozen `questions` sequentially with `AnswerButton`, counts correct
/// answers as the score, and on the last question applies that score via
/// `ChallengesProvider.propose`/`submitScore` depending on [args.mode]
/// (see C-15 design D-9).
class ChallengePlayScreen extends StatefulWidget {
  const ChallengePlayScreen({super.key, required this.args});

  final ChallengePlayArgs args;

  @override
  State<ChallengePlayScreen> createState() => _ChallengePlayScreenState();
}

class _ChallengePlayScreenState extends State<ChallengePlayScreen> {
  int _index = 0;
  int _score = 0;
  bool _finished = false;

  void _onAnswer(int optionIndex) {
    final question = widget.args.questions[_index];
    final correct = optionIndex == question.correctIndex;
    final nextScore = correct ? _score + 1 : _score;
    final isLast = _index == widget.args.questions.length - 1;

    if (isLast) {
      setState(() {
        _score = nextScore;
        _finished = true;
      });
      _finish();
    } else {
      setState(() {
        _score = nextScore;
        _index += 1;
      });
    }
  }

  void _finish() {
    final provider = context.read<ChallengesProvider>();
    final args = widget.args;
    if (args.mode == ChallengePlayMode.propose) {
      provider.propose(
        opponent: args.opponent!,
        game: args.game,
        questions: args.questions,
        fromScore: _score,
      );
    } else {
      provider.submitScore(args.challenge!, _score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameColor = gameThemes[widget.args.game]?.primaryColor;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: gameColor?.withValues(alpha: 0.85) ?? AppTheme.appBar,
        title: const Text(
          'Desafío',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: _finished ? _buildResult() : _buildQuestion(),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = widget.args.questions[_index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pregunta ${_index + 1} de ${widget.args.questions.length}',
          style: const TextStyle(color: Colors.white54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
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
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AnswerButton(
              text: question.options[i],
              onPressed: () => _onAnswer(i),
              color: Colors.deepPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return Center(
      child: Text(
        'Puntaje final: $_score / ${widget.args.questions.length}',
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
