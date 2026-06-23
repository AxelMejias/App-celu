import 'package:flutter/material.dart';

class GameTheme {
  const GameTheme({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.primaryColor,
  });

  final String id;
  final String displayName;
  final String icon;
  final Color primaryColor;
}

const Map<String, GameTheme> gameThemes = {
  'pokemon': GameTheme(
    id: 'pokemon',
    displayName: 'Pokémon',
    icon: '🔴',
    primaryColor: Color(0xFFE53935),
  ),
  'lol': GameTheme(
    id: 'lol',
    displayName: 'League of Legends',
    icon: '⚔️',
    primaryColor: Color(0xFF1565C0),
  ),
  'terraria': GameTheme(
    id: 'terraria',
    displayName: 'Terraria',
    icon: '⛏️',
    primaryColor: Color(0xFF2E7D32),
  ),
  'valorant': GameTheme(
    id: 'valorant',
    displayName: 'Valorant',
    icon: '🎯',
    primaryColor: Color(0xFFB71C1C),
  ),
  'overwatch': GameTheme(
    id: 'overwatch',
    displayName: 'Overwatch',
    icon: '🤖',
    primaryColor: Color(0xFFF57F17),
  ),
  'warframe': GameTheme(
    id: 'warframe',
    displayName: 'Warframe',
    icon: '🛸',
    primaryColor: Color(0xFF4A148C),
  ),
};
