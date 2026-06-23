import 'package:flutter/material.dart';

class SelectGameScreen extends StatelessWidget {
  const SelectGameScreen({super.key});

  static const List<Map<String, dynamic>> games = [
    {'name': 'Pokémon', 'icon': '🔴', 'color': 0xFFE53935},
    {'name': 'League of Legends', 'icon': '⚔️', 'color': 0xFF1565C0},
    {'name': 'Terraria', 'icon': '⛏️', 'color': 0xFF2E7D32},
    {'name': 'Valorant', 'icon': '🎯', 'color': 0xFFB71C1C},
    {'name': 'Overwatch', 'icon': '🤖', 'color': 0xFFF57F17},
    {'name': 'Warframe', 'icon': '🛸', 'color': 0xFF4A148C},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Elegir Juego',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return GestureDetector(
              onTap: () => Navigator.pop(context, game['name']),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(game['color'] as int).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(game['color'] as int),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(game['icon'] as String,
                        style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      game['name'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}