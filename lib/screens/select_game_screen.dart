import 'package:flutter/material.dart';
import '../theme/game_themes.dart';

class SelectGameScreen extends StatelessWidget {
  const SelectGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themes = gameThemes.values.toList();

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
          itemCount: themes.length,
          itemBuilder: (context, index) {
            final theme = themes[index];
            return GestureDetector(
              onTap: () => Navigator.pop(context, theme.id),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.primaryColor, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(theme.icon, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      theme.displayName,
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
