import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/game_themes.dart';

class AlarmRingScreen extends StatefulWidget {
  const AlarmRingScreen({super.key});

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  @override
  Widget build(BuildContext context) {
    final game = ModalRoute.of(context)?.settings.arguments as String? ?? 'pokemon';
    final gameColor = gameThemes[game]?.primaryColor ?? Colors.deepPurpleAccent;
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.alarm, size: 96, color: gameColor),
                const SizedBox(height: 24),
                Text(
                  '$hour:$minute',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Alarma!',
                  style: TextStyle(
                    color: gameColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/quiz', arguments: game),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gameColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Responder pregunta',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
