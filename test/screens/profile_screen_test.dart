import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/game_stats.dart';
import 'package:levelup_alarm/providers/auth_provider.dart';
import 'package:levelup_alarm/providers/profile_provider.dart';
import 'package:levelup_alarm/screens/profile_screen.dart';
import 'package:levelup_alarm/services/profile_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockProfileService extends Mock implements ProfileService {}

class MockUser extends Mock implements User {}

/// Auth double that tracks whether `signOut` was invoked, mirroring the
/// pattern used by test/widgets/auth_gate_test.dart.
class _FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  bool signOutCalled = false;

  @override
  User? get currentUser => MockUser();

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> register(String email, String password, String username) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

Widget _buildScreen(ProfileProvider profileProvider, _FakeAuthProvider authProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
    ],
    child: const MaterialApp(home: ProfileScreen()),
  );
}

void main() {
  late MockProfileService mockService;
  late _FakeAuthProvider fakeAuth;

  setUp(() {
    mockService = MockProfileService();
    fakeAuth = _FakeAuthProvider();
  });

  group('ProfileScreen — identity', () {
    testWidgets('muestra username y email', (tester) async {
      when(() => mockService.loadProfile('uid-1')).thenAnswer(
        (_) async => UserProfile(
          username: 'trainer',
          email: 'trainer@example.com',
          stats: {},
        ),
      );
      final provider = ProfileProvider(profileService: mockService, uid: 'uid-1');

      await tester.pumpWidget(_buildScreen(provider, fakeAuth));
      await tester.pumpAndSettle();

      expect(find.text('trainer'), findsOneWidget);
      expect(find.text('trainer@example.com'), findsOneWidget);
    });

    testWidgets('muestra CircularProgressIndicator mientras isLoading es true', (tester) async {
      when(() => mockService.loadProfile('uid-1')).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return UserProfile(username: 'trainer', email: 'trainer@example.com', stats: {});
      });
      final provider = ProfileProvider(profileService: mockService, uid: 'uid-1');

      await tester.pumpWidget(_buildScreen(provider, fakeAuth));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('ProfileScreen — stats', () {
    testWidgets('lista las estadísticas por juego', (tester) async {
      when(() => mockService.loadProfile('uid-1')).thenAnswer(
        (_) async => UserProfile(
          username: 'trainer',
          email: 'trainer@example.com',
          stats: {
            'pokemon': const GameStats(
              answered: 10,
              correct: 7,
              incorrect: 3,
              currentStreak: 2,
              bestStreak: 4,
            ),
          },
        ),
      );
      final provider = ProfileProvider(profileService: mockService, uid: 'uid-1');

      await tester.pumpWidget(_buildScreen(provider, fakeAuth));
      await tester.pumpAndSettle();

      expect(find.textContaining('10'), findsWidgets);
      expect(find.textContaining('7'), findsWidgets);
      expect(find.textContaining('3'), findsWidgets);
    });

    testWidgets('muestra totales agregados', (tester) async {
      when(() => mockService.loadProfile('uid-1')).thenAnswer(
        (_) async => UserProfile(
          username: 'trainer',
          email: 'trainer@example.com',
          stats: {
            'pokemon': const GameStats(
              answered: 10,
              correct: 7,
              incorrect: 3,
              currentStreak: 2,
              bestStreak: 4,
            ),
            'lol': const GameStats(
              answered: 5,
              correct: 2,
              incorrect: 3,
              currentStreak: 0,
              bestStreak: 2,
            ),
          },
        ),
      );
      final provider = ProfileProvider(profileService: mockService, uid: 'uid-1');

      await tester.pumpWidget(_buildScreen(provider, fakeAuth));
      await tester.pumpAndSettle();

      // Aggregated total answered = 15
      expect(find.textContaining('15'), findsWidgets);
    });

    testWidgets('juego sin datos muestra ceros', (tester) async {
      when(() => mockService.loadProfile('uid-1')).thenAnswer(
        (_) async => UserProfile(username: 'trainer', email: 'trainer@example.com', stats: {}),
      );
      final provider = ProfileProvider(profileService: mockService, uid: 'uid-1');

      await tester.pumpWidget(_buildScreen(provider, fakeAuth));
      await tester.pumpAndSettle();

      // 6 games rendered, all zeroed — Pokémon display name should appear
      expect(find.text('Pokémon'), findsOneWidget);
    });
  });

  group('ProfileScreen — sign out', () {
    testWidgets('tap en "Cerrar sesión" llama AuthProvider.signOut()', (tester) async {
      when(() => mockService.loadProfile('uid-1')).thenAnswer(
        (_) async => UserProfile(username: 'trainer', email: 'trainer@example.com', stats: {}),
      );
      final provider = ProfileProvider(profileService: mockService, uid: 'uid-1');

      await tester.pumpWidget(_buildScreen(provider, fakeAuth));
      await tester.pumpAndSettle();

      // The stats list is scrollable and virtualized — drag until the
      // sign-out button (below the 6 game cards) enters the viewport.
      await tester.dragUntilVisible(
        find.byIcon(Icons.logout),
        find.byType(Scrollable),
        const Offset(0, -300),
      );
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(fakeAuth.signOutCalled, isTrue);
    });
  });
}
