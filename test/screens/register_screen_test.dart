import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/providers/auth_provider.dart';
import 'package:levelup_alarm/screens/register_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockUser extends Mock implements User {}

/// Auth double whose `register` outcome is configurable: with `failWith` set
/// it simulates a failed registration (errorMessage populated), otherwise a
/// successful one.
class _FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  _FakeAuthProvider({this.failWith});

  final String? failWith;
  bool registerCalled = false;

  @override
  String? errorMessage;

  @override
  User? get currentUser => registerCalled && failWith == null ? MockUser() : null;

  @override
  bool get isLoading => false;

  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> register(String email, String password, String username) async {
    registerCalled = true;
    errorMessage = failWith;
    notifyListeners();
  }

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

Future<void> _pumpRegisterPushedOverRoot(
  WidgetTester tester,
  _FakeAuthProvider auth,
  GlobalKey<NavigatorState> navKey,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: MaterialApp(
        navigatorKey: navKey,
        home: const Scaffold(body: Text('ROOT')),
      ),
    ),
  );
  navKey.currentState!.push(
    MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillForm(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'axel');
  await tester.enterText(fields.at(1), 'axel@test.com');
  await tester.enterText(fields.at(2), 'test1234');
  await tester.enterText(fields.at(3), 'test1234');
}

void main() {
  testWidgets('registro exitoso vuelve a la ruta raíz (AuthGate)', (tester) async {
    final auth = _FakeAuthProvider();
    final navKey = GlobalKey<NavigatorState>();
    await _pumpRegisterPushedOverRoot(tester, auth, navKey);

    await _fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(auth.registerCalled, isTrue);
    // The pushed RegisterScreen must pop so AuthGate (root) becomes visible.
    expect(find.text('ROOT'), findsOneWidget);
    expect(find.byType(RegisterScreen), findsNothing);
  });

  testWidgets('registro fallido se queda en la pantalla y muestra el error', (tester) async {
    final auth = _FakeAuthProvider(failWith: 'El email ya está en uso');
    final navKey = GlobalKey<NavigatorState>();
    await _pumpRegisterPushedOverRoot(tester, auth, navKey);

    await _fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('El email ya está en uso'), findsOneWidget);
  });
}
