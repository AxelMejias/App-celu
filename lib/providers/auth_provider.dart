import 'dart:async';

// `hide AuthProvider`: firebase_auth exports its own abstract `AuthProvider`
// (base class for GoogleAuthProvider, EmailAuthProvider, etc.) which would
// otherwise collide with the ChangeNotifier defined in this file.
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

/// Exposes Firebase's authentication state to the widget tree as a
/// [ChangeNotifier]. Listens to [AuthService.authStateChanges] so any
/// sign-in/out — from this app instance or a restored session — is reflected
/// automatically without manual polling.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    _subscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _subscription;

  User? _currentUser;
  // Starts true: the initial Firebase auth state hasn't been resolved yet.
  bool _isLoading = true;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) => _runAuthOperation(
        () => _authService.signIn(email, password),
      );

  Future<void> register(String email, String password, String username) => _runAuthOperation(
        () => _authService.register(email, password, username),
      );

  Future<void> signInWithGoogle() => _runAuthOperation(
        () => _authService.signInWithGoogle(),
      );

  Future<void> signOut() => _authService.signOut();

  Future<void> _runAuthOperation(Future<void> Function() operation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await operation();
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
