import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/app.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
