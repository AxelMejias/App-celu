import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thrown by [AuthService] with a user-facing, Spanish-language message so
/// the UI layer never has to interpret raw [FirebaseAuthException] codes.
class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin wrapper around `firebase_auth` (+ `google_sign_in` + `cloud_firestore`)
/// so the rest of the app never talks to Firebase APIs directly. Dependencies
/// are injectable to allow mocking in tests without a real Firebase project.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  /// Emits the current [User] (or `null`) whenever the Firebase auth state
  /// changes, including on app start once the SDK has resolved the
  /// persisted session.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_signInErrorMessage(e));
    }
  }

  Future<void> register(String email, String password, String username) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid != null) {
        await _createUserDocument(uid: uid, email: email, username: username);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_registerErrorMessage(e));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User dismissed the account picker — not an error, just no-op.
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (userCredential.additionalUserInfo?.isNewUser == true && user != null) {
        await _createUserDocument(
          uid: user.uid,
          email: user.email ?? '',
          username: user.displayName ?? googleUser.displayName ?? '',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_signInErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Not signed in with Google — nothing to clear.
    }
  }

  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String username,
  }) {
    return _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _registerErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este email ya está en uso';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres)';
      case 'invalid-email':
        return 'El email ingresado no es válido';
      default:
        return 'No se pudo completar el registro. Intentá de nuevo';
    }
  }

  String _signInErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o contraseña incorrectos';
      case 'invalid-email':
        return 'El email ingresado no es válido';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada';
      default:
        return 'No se pudo iniciar sesión. Intentá de nuevo';
    }
  }
}
