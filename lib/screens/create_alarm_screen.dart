import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';
import '../theme/game_themes.dart';
import 'select_game_screen.dart';

class CreateAlarmScreen extends StatefulWidget {
  const CreateAlarmScreen({super.key});

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedGame;

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    final alarm = Alarm(time: _selectedTime, game: _selectedGame!);
    await context.read<AlarmProvider>().addAlarm(alarm);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickGame() async {
    final String? game = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectGameScreen()),
    );
    if (game != null) {
      setState(() => _selectedGame = game);
    }
  }

  String get _gameButtonLabel {
    if (_selectedGame == null) return 'Elegir juego';
    return gameThemes[_selectedGame]?.displayName ?? _selectedGame!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Nueva Alarma',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Hora de la alarma',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickTime,
              child: Text(
                _selectedTime.format(context),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Elegir hora',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedGame != null
                      ? (gameThemes[_selectedGame]?.primaryColor ?? Colors.deepPurple.shade800)
                      : Colors.deepPurple.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _gameButtonLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedGame == null ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  disabledBackgroundColor: Colors.white12,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
