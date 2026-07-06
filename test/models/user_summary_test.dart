import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/user_summary.dart';

void main() {
  group('UserSummary.fromMap/toMap', () {
    test('round-trip preserva uid y username', () {
      final map = {'uid': 'u1', 'username': 'ash'};

      final summary = UserSummary.fromMap(map);
      final result = summary.toMap();

      expect(result['uid'], 'u1');
      expect(result['username'], 'ash');
    });

    test('fromMap con username ausente usa cadena vacía', () {
      final summary = UserSummary.fromMap({'uid': 'u1'});

      expect(summary.username, '');
    });
  });
}
