import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/friend_request.dart';
import 'package:levelup_alarm/models/user_summary.dart';
import 'package:levelup_alarm/providers/friends_provider.dart';
import 'package:levelup_alarm/services/friends_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFriendsService extends Mock implements FriendsService {}

void main() {
  late MockFriendsService mockService;

  setUpAll(() {
    registerFallbackValue(
      const FriendRequest(fromUid: 'fallback-from', fromUsername: 'fallback', toUid: 'fallback-to'),
    );
  });

  setUp(() {
    mockService = MockFriendsService();
  });

  group('FriendsProvider.loadFriends', () {
    test('popula friends y deja isLoading en false', () async {
      when(() => mockService.loadFriends('u1')).thenAnswer(
        (_) async => [
          const UserSummary(uid: 'u2', username: 'misty'),
          const UserSummary(uid: 'u3', username: 'gary'),
        ],
      );
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await provider.loadFriends();

      expect(provider.friends, hasLength(2));
      expect(provider.isLoading, isFalse);
    });

    test('un fallo del servicio setea errorMessage en español e isLoading en false', () async {
      when(() => mockService.loadFriends('u1')).thenThrow(Exception('boom'));
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await provider.loadFriends();

      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
    });
  });

  group('FriendsProvider.sendRequest', () {
    test('en éxito registra el uid en sentRequestUids y notifica', () async {
      when(() => mockService.loadUsername('u1')).thenAnswer((_) async => 'ash');
      when(() => mockService.sendRequest(
            fromUid: 'u1',
            fromUsername: 'ash',
            toUid: 'u3',
            toUsername: any(named: 'toUsername'),
          )).thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.sendRequest('u3');

      expect(provider.sentRequestUids, contains('u3'));
      expect(notified, isTrue);
      expect(provider.errorMessage, isNull);
    });

    test('en fallo setea errorMessage y no marca el uid como enviado', () async {
      when(() => mockService.loadUsername('u1')).thenAnswer((_) async => 'ash');
      when(() => mockService.sendRequest(
            fromUid: any(named: 'fromUid'),
            fromUsername: any(named: 'fromUsername'),
            toUid: any(named: 'toUid'),
            toUsername: any(named: 'toUsername'),
          )).thenThrow(Exception('boom'));
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await provider.sendRequest('u3');

      expect(provider.sentRequestUids, isNot(contains('u3')));
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('FriendsProvider.loadIncomingRequests', () {
    test('popula incomingRequests', () async {
      when(() => mockService.loadIncomingRequests('u1')).thenAnswer(
        (_) async => [
          const FriendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'u1'),
        ],
      );
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await provider.loadIncomingRequests();

      expect(provider.incomingRequests, hasLength(1));
    });
  });

  group('FriendsProvider.search', () {
    test('excluye a los amigos ya presentes en friends', () async {
      when(() => mockService.loadFriends('u1')).thenAnswer(
        (_) async => [const UserSummary(uid: 'u2', username: 'misty')],
      );
      when(() => mockService.searchUsers(any(), excludeUid: 'u1')).thenAnswer(
        (_) async => [
          const UserSummary(uid: 'u2', username: 'misty'),
          const UserSummary(uid: 'u3', username: 'gary'),
        ],
      );
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');
      await provider.loadFriends();

      await provider.search('gary');

      expect(provider.searchResults, hasLength(1));
      expect(provider.searchResults.first.uid, 'u3');
    });
  });

  group('FriendsProvider.sendRequest', () {
    test('llama FriendsService.sendRequest con el username propio cacheado', () async {
      when(() => mockService.loadUsername('u1')).thenAnswer((_) async => 'ash');
      when(() => mockService.sendRequest(
            fromUid: any(named: 'fromUid'),
            fromUsername: any(named: 'fromUsername'),
            toUid: any(named: 'toUid'),
            toUsername: any(named: 'toUsername'),
          )).thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await provider.sendRequest('u2', toUsername: 'misty');

      verify(() => mockService.sendRequest(
          fromUid: 'u1', fromUsername: 'ash', toUid: 'u2', toUsername: 'misty')).called(1);
    });

    test('con uid null es no-op (no llama al servicio)', () async {
      final provider = FriendsProvider(friendsService: mockService, uid: null);

      await provider.sendRequest('u2');

      verifyNever(() => mockService.sendRequest(
            fromUid: any(named: 'fromUid'),
            fromUsername: any(named: 'fromUsername'),
            toUid: any(named: 'toUid'),
          ));
    });

    test('a uno mismo (targetUid == uid) es no-op', () async {
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await provider.sendRequest('u1');

      verifyNever(() => mockService.sendRequest(
            fromUid: any(named: 'fromUid'),
            fromUsername: any(named: 'fromUsername'),
            toUid: any(named: 'toUid'),
          ));
    });
  });

  group('FriendsProvider.loadSentRequests', () {
    test('popula sentRequests y agrega sus uids a sentRequestUids', () async {
      when(() => mockService.loadSentRequests('u1')).thenAnswer(
        (_) async => [
          const FriendRequest(fromUid: 'u1', fromUsername: 'ash', toUid: 'u2'),
        ],
      );
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await provider.loadSentRequests();

      expect(provider.sentRequests, hasLength(1));
      expect(provider.sentRequestUids, contains('u2'));
    });

    test('sentRequestUids incluye tanto lo persistido como lo enviado en la sesión', () async {
      when(() => mockService.loadSentRequests('u1')).thenAnswer(
        (_) async => [
          const FriendRequest(fromUid: 'u1', fromUsername: 'ash', toUid: 'u2'),
        ],
      );
      when(() => mockService.loadUsername('u1')).thenAnswer((_) async => 'ash');
      when(() => mockService.sendRequest(
            fromUid: any(named: 'fromUid'),
            fromUsername: any(named: 'fromUsername'),
            toUid: any(named: 'toUid'),
            toUsername: any(named: 'toUsername'),
          )).thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');
      await provider.loadSentRequests();

      await provider.sendRequest('u3');

      expect(provider.sentRequestUids, containsAll(['u2', 'u3']));
    });

    test('sin uid es no-op (no llama al servicio)', () async {
      final provider = FriendsProvider(friendsService: mockService, uid: null);

      await provider.loadSentRequests();

      verifyNever(() => mockService.loadSentRequests(any()));
    });

    test('un fallo del servicio setea errorMessage', () async {
      when(() => mockService.loadSentRequests('u1')).thenThrow(Exception('boom'));
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await provider.loadSentRequests();

      expect(provider.errorMessage, isNotNull);
    });
  });

  group('FriendsProvider.cancelSentRequest', () {
    test('borra la solicitud y la quita de sentRequests / sentRequestUids', () async {
      const request = FriendRequest(fromUid: 'u1', fromUsername: 'ash', toUid: 'u2');
      when(() => mockService.loadSentRequests('u1')).thenAnswer((_) async => [request]);
      when(() => mockService.rejectRequest(any())).thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');
      await provider.loadSentRequests();

      await provider.cancelSentRequest(request);

      expect(provider.sentRequests, isEmpty);
      expect(provider.sentRequestUids, isNot(contains('u2')));
      verify(() => mockService.rejectRequest(request)).called(1);
    });

    test('un fallo del servicio setea errorMessage en español y conserva la solicitud', () async {
      const request = FriendRequest(fromUid: 'u1', fromUsername: 'ash', toUid: 'u2');
      when(() => mockService.loadSentRequests('u1')).thenAnswer((_) async => [request]);
      when(() => mockService.rejectRequest(any())).thenThrow(Exception('boom'));
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');
      await provider.loadSentRequests();

      await provider.cancelSentRequest(request);

      expect(provider.errorMessage, isNotNull);
      expect(provider.sentRequests, hasLength(1));
    });
  });

  group('FriendsProvider.accept', () {
    test('llama acceptRequest, agrega el amigo a friends y quita la solicitud de incomingRequests',
        () async {
      const request = FriendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'u1');
      when(() => mockService.loadIncomingRequests('u1')).thenAnswer((_) async => [request]);
      when(() => mockService.loadUsername('u1')).thenAnswer((_) async => 'misty');
      when(() => mockService.acceptRequest(request: any(named: 'request'), myUsername: any(named: 'myUsername')))
          .thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');
      await provider.loadIncomingRequests();

      await provider.accept(request);

      expect(provider.incomingRequests, isEmpty);
      expect(provider.friends, hasLength(1));
      expect(provider.friends.first.uid, 'a');
    });
  });

  group('FriendsProvider.reject', () {
    test('llama rejectRequest y quita la solicitud de incomingRequests', () async {
      const request = FriendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'u1');
      when(() => mockService.loadIncomingRequests('u1')).thenAnswer((_) async => [request]);
      when(() => mockService.rejectRequest(any())).thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');
      await provider.loadIncomingRequests();

      await provider.reject(request);

      expect(provider.incomingRequests, isEmpty);
      verify(() => mockService.rejectRequest(request)).called(1);
    });
  });
}
