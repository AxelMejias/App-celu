import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/app.dart';

import 'helpers/fake_signed_in_auth_provider.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(App(authProviderOverride: FakeSignedInAuthProvider()));
    expect(find.byType(App), findsOneWidget);
  });
}
