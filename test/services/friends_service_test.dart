import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levelup_alarm/models/friend_request.dart';
import 'package:levelup_alarm/services/friends_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FriendsService friendsService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    friendsService = FriendsService(firestore: firestore);
  });

  Future<void> seedUser(String uid, {required String username}) {
    return firestore.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
    });
  }

  group('FriendsService.searchUsers', () {
    test("searchUsers('misty', excludeUid: 'u1') devuelve un UserSummary con uid u2", () async {
      await seedUser('u2', username: 'misty');

      final results = await friendsService.searchUsers('misty', excludeUid: 'u1');

      expect(results, hasLength(1));
      expect(results.first.uid, 'u2');
      expect(results.first.username, 'misty');
    });

    test('searchUsers excluye al propio usuario', () async {
      await seedUser('u1', username: 'ash');

      final results = await friendsService.searchUsers('ash', excludeUid: 'u1');

      expect(results, isEmpty);
    });

    test('searchUsers sin coincidencias devuelve lista vacía', () async {
      await seedUser('u2', username: 'misty');

      final results = await friendsService.searchUsers('zzz', excludeUid: 'u1');

      expect(results, isEmpty);
    });
  });

  group('FriendsService.sendRequest', () {
    test('sendRequest crea friendRequests/a_b con status pending', () async {
      await friendsService.sendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'b');

      final doc = await firestore.collection('friendRequests').doc('a_b').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['fromUid'], 'a');
      expect(doc.data()!['toUid'], 'b');
      expect(doc.data()!['status'], 'pending');
    });

    test('sendRequest persiste toUsername para mostrarlo en Solicitudes enviadas', () async {
      await friendsService.sendRequest(
          fromUid: 'a', fromUsername: 'ash', toUid: 'b', toUsername: 'misty');

      final doc = await firestore.collection('friendRequests').doc('a_b').get();
      expect(doc.data()!['toUsername'], 'misty');

      final results = await friendsService.loadSentRequests('a');
      expect(results.first.toUsername, 'misty');
    });

    test('sendRequest dos veces es idempotente (un solo doc a_b)', () async {
      await friendsService.sendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'b');
      await friendsService.sendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'b');

      final snapshot = await firestore.collection('friendRequests').get();
      expect(snapshot.docs, hasLength(1));
    });
  });

  group('FriendsService.loadIncomingRequests', () {
    test('devuelve solo las solicitudes con toUid == uid', () async {
      await friendsService.sendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'b');
      await friendsService.sendRequest(fromUid: 'c', fromUsername: 'gary', toUid: 'd');

      final results = await friendsService.loadIncomingRequests('b');

      expect(results, hasLength(1));
      expect(results.first.fromUid, 'a');
      expect(results.first.toUid, 'b');
    });

    test('sin solicitudes devuelve lista vacía', () async {
      final results = await friendsService.loadIncomingRequests('b');

      expect(results, isEmpty);
    });
  });

  group('FriendsService.loadSentRequests', () {
    test('devuelve solo las solicitudes con fromUid == uid', () async {
      await friendsService.sendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'b');
      await friendsService.sendRequest(fromUid: 'c', fromUsername: 'gary', toUid: 'd');

      final results = await friendsService.loadSentRequests('a');

      expect(results, hasLength(1));
      expect(results.first.fromUid, 'a');
      expect(results.first.toUid, 'b');
    });

    test('ignora las solicitudes de otros emisores', () async {
      await friendsService.sendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'b');
      await friendsService.sendRequest(fromUid: 'c', fromUsername: 'gary', toUid: 'd');

      final results = await friendsService.loadSentRequests('c');

      expect(results, hasLength(1));
      expect(results.first.fromUid, 'c');
      expect(results.first.toUid, 'd');
    });

    test('sin solicitudes enviadas devuelve lista vacía', () async {
      final results = await friendsService.loadSentRequests('a');

      expect(results, isEmpty);
    });
  });

  group('FriendsService.acceptRequest', () {
    test('crea users/b/friends/a y users/a/friends/b y borra la solicitud', () async {
      const request = FriendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'b');

      await friendsService.acceptRequest(request: request, myUsername: 'misty');

      final toFriendDoc =
          await firestore.collection('users').doc('b').collection('friends').doc('a').get();
      final fromFriendDoc =
          await firestore.collection('users').doc('a').collection('friends').doc('b').get();
      expect(toFriendDoc.exists, isTrue);
      expect(fromFriendDoc.exists, isTrue);

      final requestDoc = await firestore.collection('friendRequests').doc('a_b').get();
      expect(requestDoc.exists, isFalse);
    });

    test('deja el username correcto en cada dirección', () async {
      const request = FriendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'b');

      await friendsService.acceptRequest(request: request, myUsername: 'misty');

      final toFriendDoc =
          await firestore.collection('users').doc('b').collection('friends').doc('a').get();
      final fromFriendDoc =
          await firestore.collection('users').doc('a').collection('friends').doc('b').get();
      expect(toFriendDoc.data()!['username'], 'ash');
      expect(fromFriendDoc.data()!['username'], 'misty');
    });
  });

  group('FriendsService.rejectRequest', () {
    test('borra la solicitud y no crea amistad', () async {
      await friendsService.sendRequest(fromUid: 'a', fromUsername: 'ash', toUid: 'b');
      final request = FriendRequest.fromMap(
        (await firestore.collection('friendRequests').doc('a_b').get()).data()!,
      );

      await friendsService.rejectRequest(request);

      final requestDoc = await firestore.collection('friendRequests').doc('a_b').get();
      expect(requestDoc.exists, isFalse);
      final toFriendDoc =
          await firestore.collection('users').doc('b').collection('friends').doc('a').get();
      final fromFriendDoc =
          await firestore.collection('users').doc('a').collection('friends').doc('b').get();
      expect(toFriendDoc.exists, isFalse);
      expect(fromFriendDoc.exists, isFalse);
    });
  });

  group('FriendsService.loadFriends', () {
    test('devuelve los UserSummary de users/{uid}/friends', () async {
      await firestore
          .collection('users')
          .doc('u1')
          .collection('friends')
          .doc('u2')
          .set({'uid': 'u2', 'username': 'misty'});

      final results = await friendsService.loadFriends('u1');

      expect(results, hasLength(1));
      expect(results.first.uid, 'u2');
      expect(results.first.username, 'misty');
    });

    test('sin amigos devuelve lista vacía', () async {
      final results = await friendsService.loadFriends('u1');

      expect(results, isEmpty);
    });
  });

  group('FriendsService.loadUsername', () {
    test('devuelve el username del documento users/{uid}', () async {
      await seedUser('u1', username: 'ash');

      final username = await friendsService.loadUsername('u1');

      expect(username, 'ash');
    });

    test('devuelve cadena vacía si el documento no tiene username', () async {
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});

      final username = await friendsService.loadUsername('u1');

      expect(username, '');
    });
  });
}
