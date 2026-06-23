import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/screens/success_screen.dart';

void main() {
  group('SuccessScreen', () {
    testWidgets('renders success message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/success',
          routes: {
            '/': (_) => const Scaffold(body: Text('Home')),
            '/success': (_) => const SuccessScreen(),
          },
        ),
      );

      expect(find.text('¡Correcto!'), findsOneWidget);

      // Advance past the 3-second auto-navigation timer
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // After navigation, SuccessScreen is gone
      expect(find.text('¡Correcto!'), findsNothing);
    });
  });
}
