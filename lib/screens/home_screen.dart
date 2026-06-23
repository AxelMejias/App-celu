import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';
import 'create_alarm_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alarms = context.watch<AlarmProvider>().alarms;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'LevelUp Alarm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: alarms.isEmpty ? _buildEmptyState() : _buildAlarmList(context, alarms),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No hay alarmas todavía.\nPresioná + para crear una.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white54, fontSize: 16),
      ),
    );
  }

  Widget _buildAlarmList(BuildContext context, List<Alarm> alarms) {
    return ListView.builder(
      itemCount: alarms.length,
      itemBuilder: (context, index) {
        final alarm = alarms[index];
        return _AlarmTile(alarm: alarm);
      },
    );
  }
}

class _AlarmTile extends StatelessWidget {
  const _AlarmTile({required this.alarm});

  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AlarmProvider>();

    return ListTile(
      tileColor: const Color(0xFF16213E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Switch(
        value: alarm.isActive,
        activeThumbColor: Colors.deepPurpleAccent,
        onChanged: (_) => provider.toggleAlarm(alarm.id),
      ),
      title: Text(
        alarm.time.format(context),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        alarm.game,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.white38),
        onPressed: () => provider.deleteAlarm(alarm.id),
      ),
    );
  }
}
