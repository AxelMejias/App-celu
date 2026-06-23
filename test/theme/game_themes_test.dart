import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/theme/game_themes.dart';

void main() {
  group('gameThemes — completeness', () {
    test('contains all 6 canonical game IDs', () {
      expect(gameThemes.keys, containsAll([
        'pokemon', 'lol', 'terraria', 'valorant', 'overwatch', 'warframe',
      ]));
      expect(gameThemes.length, 6);
    });

    test('each theme id matches its map key', () {
      for (final entry in gameThemes.entries) {
        expect(entry.value.id, entry.key,
            reason: 'theme.id should equal map key for ${entry.key}');
      }
    });

    test('each theme has non-empty displayName', () {
      for (final theme in gameThemes.values) {
        expect(theme.displayName, isNotEmpty,
            reason: 'displayName empty for ${theme.id}');
      }
    });

    test('each theme has non-empty icon', () {
      for (final theme in gameThemes.values) {
        expect(theme.icon, isNotEmpty,
            reason: 'icon empty for ${theme.id}');
      }
    });

    test('pokemon displayName is "Pokémon"', () {
      expect(gameThemes['pokemon']?.displayName, 'Pokémon');
    });

    test('lol displayName is "League of Legends"', () {
      expect(gameThemes['lol']?.displayName, 'League of Legends');
    });
  });
}
