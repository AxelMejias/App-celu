import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/services/profile_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProfileService profileService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    profileService = ProfileService(firestore: firestore);
  });

  Future<void> seedUser(
    String uid, {
    String username = 'trainer',
    String email = 'trainer@example.com',
    Map<String, dynamic>? stats,
  }) {
    return firestore.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
      'email': email,
      'stats': ?stats,
    });
  }

  group('ProfileService.loadProfile', () {
    test('loadProfile devuelve username, email y stats por juego', () async {
      await seedUser(
        'uid-1',
        stats: {
          'pokemon': {
            'answered': 10,
            'correct': 7,
            'incorrect': 3,
            'currentStreak': 2,
            'bestStreak': 4,
          },
        },
      );

      final profile = await profileService.loadProfile('uid-1');

      expect(profile.username, 'trainer');
      expect(profile.email, 'trainer@example.com');
      expect(profile.stats['pokemon']?.answered, 10);
      expect(profile.stats['pokemon']?.correct, 7);
    });

    test('loadProfile sin campo stats devuelve GameStats.empty() por juego', () async {
      await seedUser('uid-2');

      final profile = await profileService.loadProfile('uid-2');

      expect(profile.stats, isEmpty);
    });
  });

  group('ProfileService.recordAnswer', () {
    test(
        'recordAnswer(correct) incrementa answered/correct/currentStreak y mantiene bestStreak',
        () async {
      await seedUser(
        'uid-3',
        stats: {
          'pokemon': {
            'answered': 5,
            'correct': 3,
            'incorrect': 2,
            'currentStreak': 2,
            'bestStreak': 3,
          },
        },
      );

      await profileService.recordAnswer('uid-3', 'pokemon', true);

      final doc = await firestore.collection('users').doc('uid-3').get();
      final gameStats = (doc.data()!['stats'] as Map<String, dynamic>)['pokemon']
          as Map<String, dynamic>;
      expect(gameStats['answered'], 6);
      expect(gameStats['correct'], 4);
      expect(gameStats['currentStreak'], 3);
      expect(gameStats['bestStreak'], 3);
    });

    test('recordAnswer(correct) sube bestStreak cuando currentStreak lo supera', () async {
      await seedUser(
        'uid-4',
        stats: {
          'pokemon': {
            'answered': 5,
            'correct': 3,
            'incorrect': 2,
            'currentStreak': 3,
            'bestStreak': 3,
          },
        },
      );

      await profileService.recordAnswer('uid-4', 'pokemon', true);

      final doc = await firestore.collection('users').doc('uid-4').get();
      final gameStats = (doc.data()!['stats'] as Map<String, dynamic>)['pokemon']
          as Map<String, dynamic>;
      expect(gameStats['currentStreak'], 4);
      expect(gameStats['bestStreak'], 4);
    });

    test(
        'recordAnswer(incorrect) incrementa incorrect y resetea currentStreak a 0, mantiene bestStreak',
        () async {
      await seedUser(
        'uid-5',
        stats: {
          'pokemon': {
            'answered': 10,
            'correct': 5,
            'incorrect': 5,
            'currentStreak': 5,
            'bestStreak': 5,
          },
        },
      );

      await profileService.recordAnswer('uid-5', 'pokemon', false);

      final doc = await firestore.collection('users').doc('uid-5').get();
      final gameStats = (doc.data()!['stats'] as Map<String, dynamic>)['pokemon']
          as Map<String, dynamic>;
      expect(gameStats['answered'], 11);
      expect(gameStats['incorrect'], 6);
      expect(gameStats['currentStreak'], 0);
      expect(gameStats['bestStreak'], 5);
    });

    test('recordAnswer inicializa stats de un juego sin datos previos', () async {
      await seedUser('uid-6');

      await profileService.recordAnswer('uid-6', 'lol', true);

      final doc = await firestore.collection('users').doc('uid-6').get();
      final gameStats =
          (doc.data()!['stats'] as Map<String, dynamic>)['lol'] as Map<String, dynamic>;
      expect(gameStats['answered'], 1);
      expect(gameStats['correct'], 1);
      expect(gameStats['currentStreak'], 1);
      expect(gameStats['bestStreak'], 1);
    });

    test('recordAnswer no borra las estadísticas de otros juegos', () async {
      await seedUser(
        'uid-7',
        stats: {
          'pokemon': {
            'answered': 2,
            'correct': 2,
            'incorrect': 0,
            'currentStreak': 2,
            'bestStreak': 2,
          },
        },
      );

      await profileService.recordAnswer('uid-7', 'lol', true);

      final doc = await firestore.collection('users').doc('uid-7').get();
      final allStats = doc.data()!['stats'] as Map<String, dynamic>;
      expect(allStats['pokemon'], isNotNull);
      expect((allStats['pokemon'] as Map<String, dynamic>)['answered'], 2);
      expect((allStats['lol'] as Map<String, dynamic>)['answered'], 1);
    });
  });
}
