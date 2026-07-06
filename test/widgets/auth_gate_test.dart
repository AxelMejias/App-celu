import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/providers/alarm_provider.dart';
import 'package:levelup_alarm/providers/auth_provider.dart';
import 'package:levelup_alarm/screens/home_screen.dart';
import 'package:levelup_alarm/screens/login_screen.dart';
import 'package:levelup_alarm/widgets/auth_gate.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUser extends Mock implements User {}

/// Test double that exposes the same read surface as [AuthProvider] but with
/// directly settable fields, so AuthGate's branching can be tested without a
/// real Firebase stream.
class _FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  _FakeAuthProvider({this.currentUser, this.isLoading = false});

  @override
  final User? currentUser;

  @override
  final bool isLoading;

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

Widget _buildGate(AuthProvider authProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ChangeNotifierProvider<AlarmProvider>(create: (_) => AlarmProvider()),
    ],
    child: const MaterialApp(home: AuthGate()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows HomeScreen when user is non-null', (tester) async {
    final fakeAuth = _FakeAuthProvider(currentUser: MockUser());

    await tester.pumpWidget(_buildGate(fakeAuth));
    await tester.pump();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('shows LoginScreen when user is null', (tester) async {
    final fakeAuth = _FakeAuthProvider();

    await tester.pumpWidget(_buildGate(fakeAuth));
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('shows loading indicator while auth state is resolving', (tester) async {
    final fakeAuth = _FakeAuthProvider(isLoading: true);

    await tester.pumpWidget(_buildGate(fakeAuth));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(HomeScreen), findsNothing);
  });
}
