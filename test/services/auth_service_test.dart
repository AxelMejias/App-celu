import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:levelup_alarm/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAdditionalUserInfo extends Mock implements AdditionalUserInfo {}

class MockUser extends Mock implements User {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthService authService;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockGoogleSignIn = MockGoogleSignIn();

    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);
    when(() => mockDocument.set(any())).thenAnswer((_) async {});

    authService = AuthService(
      auth: mockAuth,
      firestore: mockFirestore,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('AuthService.signIn', () {
    test('calls FirebaseAuth.signInWithEmailAndPassword with given credentials', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => MockUserCredential());

      await authService.signIn('user@example.com', 'secret1');

      verify(() => mockAuth.signInWithEmailAndPassword(
            email: 'user@example.com',
            password: 'secret1',
          )).called(1);
    });

    test('throws AuthException with Spanish message on wrong-password', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      expect(
        () => authService.signIn('user@example.com', 'wrong'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Email o contraseña incorrectos',
          ),
        ),
      );
    });
  });

  group('AuthService.register', () {
    test('creates account and Firestore user document', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('uid-123');
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      await authService.register('new@example.com', 'secret1', 'newuser');

      verify(() => mockCollection.doc('uid-123')).called(1);
      final captured = verify(() => mockDocument.set(captureAny())).captured;
      final data = captured.single as Map<String, dynamic>;
      expect(data['uid'], 'uid-123');
      expect(data['email'], 'new@example.com');
      expect(data['username'], 'newuser');
    });

    test('throws AuthException when email already in use', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => authService.register('taken@example.com', 'secret1', 'user'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Este email ya está en uso',
          ),
        ),
      );
    });
  });

  group('AuthService.signInWithGoogle', () {
    test('signs in with Google credential and creates user doc when new user', () async {
      final googleAccount = MockGoogleSignInAccount();
      final googleAuth = MockGoogleSignInAuthentication();
      when(() => googleAuth.accessToken).thenReturn('access-token');
      when(() => googleAuth.idToken).thenReturn('id-token');
      when(() => googleAccount.authentication).thenAnswer((_) async => googleAuth);
      when(() => googleAccount.displayName).thenReturn('New User');
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => googleAccount);

      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('google-uid');
      when(() => mockUser.email).thenReturn('googleuser@example.com');
      when(() => mockUser.displayName).thenReturn('New User');

      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);
      final additionalUserInfo = MockAdditionalUserInfo();
      when(() => additionalUserInfo.isNewUser).thenReturn(true);
      when(() => mockCredential.additionalUserInfo).thenReturn(additionalUserInfo);

      when(() => mockAuth.signInWithCredential(any())).thenAnswer((_) async => mockCredential);

      await authService.signInWithGoogle();

      verify(() => mockAuth.signInWithCredential(any())).called(1);
      verify(() => mockCollection.doc('google-uid')).called(1);
    });

    test('returns without throwing when user cancels sign-in', () async {
      when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      await authService.signInWithGoogle();

      verifyNever(() => mockAuth.signInWithCredential(any()));
    });
  });

  group('AuthService.signOut', () {
    test('calls FirebaseAuth.signOut and GoogleSignIn.signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });
  });
}
