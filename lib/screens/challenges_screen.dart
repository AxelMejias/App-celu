import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/challenge.dart';
import '../providers/challenges_provider.dart';
import '../theme/app_theme.dart';
import 'challenge_play_screen.dart';

/// Challenge inbox: received (playable), sent (waiting on the opponent) and
/// history (completed, with the result) — see C-15 design D-7, D-9.
/// Talks only to `ChallengesProvider` — no direct Firestore access.
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChallengesProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChallengesProvider>();
    final noChallenges =
        provider.incoming.isEmpty && provider.sent.isEmpty && provider.history.isEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.appBar,
        title: const Text(
          'Desafíos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: noChallenges
            ? const Center(
                child: Text(
                  'No tenés desafíos todavía.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (provider.incoming.isNotEmpty) ...[
                    _sectionTitle('Recibidos'),
                    const SizedBox(height: 8),
                    ...provider.incoming.map((c) => _incomingTile(context, c)),
                    const SizedBox(height: 24),
                  ],
                  if (provider.sent.isNotEmpty) ...[
                    _sectionTitle('Enviados'),
                    const SizedBox(height: 8),
                    ...provider.sent.map((c) => _sentTile(c)),
                    const SizedBox(height: 24),
                  ],
                  if (provider.history.isNotEmpty) ...[
                    _sectionTitle('Historial'),
                    const SizedBox(height: 8),
                    ...provider.history.map((c) => _historyTile(provider, c)),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      );

  Widget _incomingTile(BuildContext context, Challenge challenge) {
    return ListTile(
      tileColor: AppTheme.appBar,
      title: Text(challenge.fromUsername, style: const TextStyle(color: Colors.white)),
      subtitle: Text(challenge.game, style: const TextStyle(color: Colors.white54)),
      trailing: TextButton(
        onPressed: () => Navigator.pushNamed(
          context,
          '/challenge-play',
          arguments: ChallengePlayArgs.respond(challenge),
        ),
        child: const Text('Jugar'),
      ),
    );
  }

  Widget _sentTile(Challenge challenge) {
    return ListTile(
      tileColor: AppTheme.appBar,
      title: Text(challenge.toUsername, style: const TextStyle(color: Colors.white)),
      subtitle: const Text('Esperando al rival', style: TextStyle(color: Colors.white54)),
    );
  }

  Widget _historyTile(ChallengesProvider provider, Challenge challenge) {
    final myUid = provider.uid;
    final resultLabel = challenge.isDraw
        ? 'Empate'
        : (challenge.winnerUid == myUid ? 'Ganaste' : 'Perdiste');
    final opponentName = challenge.fromUid == myUid ? challenge.toUsername : challenge.fromUsername;

    return ListTile(
      tileColor: AppTheme.appBar,
      title: Text(opponentName, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        '${challenge.fromScore} - ${challenge.toScore ?? 0}',
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: Text(
        resultLabel,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
