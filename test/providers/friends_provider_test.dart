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
          )).thenAnswer((_) async {});
      final provider = FriendsProvider(friendsService: mockService, uid: 'u1');

      await provider.sendRequest('u2');

      verify(() => mockService.sendRequest(fromUid: 'u1', fromUsername: 'ash', toUid: 'u2'))
          .called(1);
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
