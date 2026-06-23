import 'package:flutter/material.dart';
import 'create_alarm_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'LevelUp Alarm',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No hay alarmas todavía.\nPresioná + para crear una.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 32),
            // TODO(C-07): remove this test button when real alarms are wired up
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/alarm-ring'),
              icon: const Icon(Icons.play_arrow, color: Colors.deepPurpleAccent),
              label: const Text(
                'Probar flujo',
                style: TextStyle(color: Colors.deepPurpleAccent),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.deepPurpleAccent),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateAlarmScreen()),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}