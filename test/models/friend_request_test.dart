import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/friend_request.dart';

void main() {
  group('FriendRequest.fromMap/toMap', () {
    test('round-trip preserva fromUid, fromUsername, toUid y status', () {
      final map = {
        'fromUid': 'a',
        'fromUsername': 'ash',
        'toUid': 'b',
        'status': 'pending',
      };

      final request = FriendRequest.fromMap(map);
      final result = request.toMap();

      expect(result['fromUid'], 'a');
      expect(result['fromUsername'], 'ash');
      expect(result['toUid'], 'b');
      expect(result['status'], 'pending');
    });

    test('fromMap sin status cae a pending', () {
      final request = FriendRequest.fromMap({
        'fromUid': 'a',
        'fromUsername': 'ash',
        'toUid': 'b',
      });

      expect(request.status, 'pending');
    });
  });

  group('requestId', () {
    test('concatena fromUid y toUid con guion bajo', () {
      expect(requestId('a', 'b'), 'a_b');
    });
  });
}
