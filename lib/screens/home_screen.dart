import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';
import '../theme/game_themes.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
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
    final theme = gameThemes[alarm.game];
    final gameColor = theme?.primaryColor ?? Colors.deepPurple;
    final gameIcon = theme?.icon ?? '🎮';

    return ListTile(
      tileColor: const Color(0xFF16213E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: gameColor.withValues(alpha: 0.2),
        child: Text(gameIcon, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(
        alarm.time.format(context),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        theme?.displayName ?? alarm.game,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: alarm.isActive,
            activeThumbColor: gameColor,
            onChanged: (_) => provider.toggleAlarm(alarm.id),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white38),
            onPressed: () => provider.deleteAlarm(alarm.id),
          ),
        ],
      ),
    );
  }
}
