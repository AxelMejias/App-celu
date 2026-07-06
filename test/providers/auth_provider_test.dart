import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/providers/auth_provider.dart';
import 'package:levelup_alarm/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {
  final StreamController<User?> controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => controller.stream;
}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  tearDown(() {
    mockAuthService.controller.close();
  });

  group('AuthProvider — initial state', () {
    test('currentUser is null initially', () {
      final provider = AuthProvider(authService: mockAuthService);
      expect(provider.currentUser, isNull);
    });

    test('isLoading is true before the auth stream emits its first value', () {
      final provider = AuthProvider(authService: mockAuthService);
      expect(provider.isLoading, isTrue);
    });
  });

  group('AuthProvider — authStateChanges', () {
    test('currentUser updates and isLoading clears when stream emits a user', () async {
      final provider = AuthProvider(authService: mockAuthService);
      final user = MockUser();

      mockAuthService.controller.add(user);
      await Future<void>.delayed(Duration.zero);

      expect(provider.currentUser, same(user));
      expect(provider.isLoading, isFalse);
    });

    test('currentUser is null and isLoading clears when stream emits null', () async {
      final provider = AuthProvider(authService: mockAuthService);

      mockAuthService.controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(provider.currentUser, isNull);
      expect(provider.isLoading, isFalse);
    });
  });

  group('AuthProvider — signIn', () {
    test('errorMessage is set after failed signIn', () async {
      when(() => mockAuthService.signIn(any(), any()))
          .thenThrow(AuthException('Email o contraseña incorrectos'));
      final provider = AuthProvider(authService: mockAuthService);

      await provider.signIn('user@example.com', 'wrong');

      expect(provider.errorMessage, 'Email o contraseña incorrectos');
      expect(provider.isLoading, isFalse);
    });

    test('errorMessage stays null after successful signIn', () async {
      when(() => mockAuthService.signIn(any(), any())).thenAnswer((_) async {});
      final provider = AuthProvider(authService: mockAuthService);

      await provider.signIn('user@example.com', 'secret1');

      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);
    });
  });
}
