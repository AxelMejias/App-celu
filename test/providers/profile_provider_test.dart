import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/game_stats.dart';
import 'package:levelup_alarm/providers/profile_provider.dart';
import 'package:levelup_alarm/services/profile_service.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileService extends Mock implements ProfileService {}

void main() {
  late MockProfileService mockService;

  setUp(() {
    mockService = MockProfileService();
  });

  group('ProfileProvider.load', () {
    test('load() popula username/email/stats y deja isLoading en false', () async {
      when(() => mockService.loadProfile('uid-1')).thenAnswer(
        (_) async => UserProfile(
          username: 'trainer',
          email: 'trainer@example.com',
          stats: {'pokemon': GameStats.empty()},
        ),
      );
      final provider = ProfileProvider(profileService: mockService, uid: 'uid-1');

      await provider.load();

      expect(provider.username, 'trainer');
      expect(provider.email, 'trainer@example.com');
      expect(provider.stats['pokemon'], GameStats.empty());
      expect(provider.isLoading, isFalse);
    });

    test('load() setea errorMessage y isLoading=false cuando el servicio lanza', () async {
      when(() => mockService.loadProfile('uid-1')).thenThrow(Exception('boom'));
      final provider = ProfileProvider(profileService: mockService, uid: 'uid-1');

      await provider.load();

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
    });
  });

  group('ProfileProvider.recordAnswer', () {
    test('recordAnswer(correct) llama ProfileService.recordAnswer y actualiza stats en memoria',
        () async {
      when(() => mockService.loadProfile('uid-1')).thenAnswer(
        (_) async => UserProfile(
          username: 'trainer',
          email: 'trainer@example.com',
          stats: {
            'pokemon': const GameStats(
              answered: 1,
              correct: 1,
              incorrect: 0,
              currentStreak: 1,
              bestStreak: 1,
            ),
          },
        ),
      );
      when(() => mockService.recordAnswer('uid-1', 'pokemon', true))
          .thenAnswer((_) async {});
      final provider = ProfileProvider(profileService: mockService, uid: 'uid-1');
      await provider.load();

      await provider.recordAnswer('pokemon', true);

      verify(() => mockService.recordAnswer('uid-1', 'pokemon', true)).called(1);
      expect(provider.stats['pokemon']?.answered, 2);
      expect(provider.stats['pokemon']?.correct, 2);
      expect(provider.stats['pokemon']?.currentStreak, 2);
    });

    test('recordAnswer sin usuario (uid null) es no-op y no llama al servicio', () async {
      final provider = ProfileProvider(profileService: mockService, uid: null);

      await provider.recordAnswer('pokemon', true);

      verifyNever(() => mockService.recordAnswer(any(), any(), any()));
    });
  });
}
