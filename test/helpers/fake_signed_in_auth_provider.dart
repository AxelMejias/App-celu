import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:levelup_alarm/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

/// Signed-in [AuthProvider] test double. Lets widget tests that pump `App()`
/// (or anything under `AuthGate`) render straight into `HomeScreen` without a
/// real Firebase connection. AuthGate's own branching logic is covered
/// directly in test/widgets/auth_gate_test.dart.
class FakeSignedInAuthProvider extends ChangeNotifier implements AuthProvider {
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
  Future<void> signOut() async {}
}
