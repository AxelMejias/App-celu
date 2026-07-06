import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/game_stats.dart';
import 'package:levelup_alarm/models/user_summary.dart';
import 'package:levelup_alarm/screens/friend_profile_screen.dart';
import 'package:levelup_alarm/services/profile_service.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileService extends Mock implements ProfileService {}

Widget _buildScreen(ProfileService profileService, UserSummary friend) {
  return MaterialApp(
    home: FriendProfileScreen(friend: friend, profileService: profileService),
  );
}

void main() {
  late MockProfileService mockService;
  const friend = UserSummary(uid: 'u2', username: 'misty');

  setUp(() {
    mockService = MockProfileService();
  });

  testWidgets('muestra el username y las estadísticas del amigo', (tester) async {
    when(() => mockService.loadProfile('u2')).thenAnswer(
      (_) async => UserProfile(
        username: 'misty',
        email: 'misty@example.com',
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

    await tester.pumpWidget(_buildScreen(mockService, friend));
    await tester.pumpAndSettle();

    expect(find.text('misty'), findsWidgets);
    expect(find.textContaining('10'), findsWidgets);
  });

  testWidgets('muestra CircularProgressIndicator mientras carga', (tester) async {
    when(() => mockService.loadProfile('u2')).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return UserProfile(username: 'misty', email: 'misty@example.com', stats: {});
    });

    await tester.pumpWidget(_buildScreen(mockService, friend));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('no muestra el botón "Cerrar sesión"', (tester) async {
    when(() => mockService.loadProfile('u2')).thenAnswer(
      (_) async => UserProfile(username: 'misty', email: 'misty@example.com', stats: {}),
    );

    await tester.pumpWidget(_buildScreen(mockService, friend));
    await tester.pumpAndSettle();

    expect(find.text('Cerrar sesión'), findsNothing);
  });
}
