import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/friend_request.dart';
import '../models/user_summary.dart';

/// Thin wrapper over `cloud_firestore` for the friendship data model:
/// searching users, sending/accepting/rejecting friend requests, and
/// listing friends. Firestore is injectable so tests run against
/// `fake_cloud_firestore` without a real project (see C-14 design D-7,
/// mirrors C-13 design D-7 on `ProfileService`).
class FriendsService {
  FriendsService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Users whose `username` matches [username] exactly, excluding
  /// [excludeUid] (see C-14 design D-5, D-7).
  Future<List<UserSummary>> searchUsers(String username, {required String excludeUid}) async {
    final snapshot =
        await _firestore.collection('users').where('username', isEqualTo: username).get();

    return snapshot.docs
        .where((doc) => doc.id != excludeUid)
        .map((doc) => UserSummary.fromMap(doc.data()))
        .toList();
  }

  /// Creates (or re-creates, idempotently) a pending friend request at
  /// `friendRequests/{fromUid}_{toUid}` (see C-14 design D-4).
  Future<void> sendRequest({
    required String fromUid,
    required String fromUsername,
    required String toUid,
    String toUsername = '',
  }) async {
    final request = FriendRequest(
        fromUid: fromUid, fromUsername: fromUsername, toUid: toUid, toUsername: toUsername);
    await _firestore
        .collection('friendRequests')
        .doc(requestId(fromUid, toUid))
        .set({
      ...request.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Pending friend requests addressed to [uid].
  Future<List<FriendRequest>> loadIncomingRequests(String uid) async {
    return _loadRequestsWhere('toUid', uid);
  }

  /// Pending friend requests originated by [uid] (see C-17 design D-1).
  /// Mirrors [loadIncomingRequests], filtering by `fromUid` instead of
  /// `toUid`, so a sent request can be shown as "Enviada" even after the app
  /// restarts (not only during the session it was sent in).
  Future<List<FriendRequest>> loadSentRequests(String uid) async {
    return _loadRequestsWhere('fromUid', uid);
  }

  Future<List<FriendRequest>> _loadRequestsWhere(String field, String value) async {
    final snapshot =
        await _firestore.collection('friendRequests').where(field, isEqualTo: value).get();

    return snapshot.docs.map((doc) => FriendRequest.fromMap(doc.data())).toList();
  }

  /// Accepts [request]: atomically creates the friendship in both
  /// directions and deletes the request document (see C-14 design D-2).
  Future<void> acceptRequest({required FriendRequest request, required String myUsername}) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    final toFriendRef =
        _firestore.collection('users').doc(request.toUid).collection('friends').doc(request.fromUid);
    final fromFriendRef =
        _firestore.collection('users').doc(request.fromUid).collection('friends').doc(request.toUid);
    final requestRef = _firestore.collection('friendRequests').doc(requestId(request.fromUid, request.toUid));

    batch.set(toFriendRef, {
      'uid': request.fromUid,
      'username': request.fromUsername,
      'since': now,
    });
    batch.set(fromFriendRef, {
      'uid': request.toUid,
      'username': myUsername,
      'since': now,
    });
    batch.delete(requestRef);

    await batch.commit();
  }

  /// Rejects [request]: deletes the request document without creating any
  /// friendship (see C-14 design, Requirement "Rechazar una solicitud").
  Future<void> rejectRequest(FriendRequest request) async {
    await _firestore
        .collection('friendRequests')
        .doc(requestId(request.fromUid, request.toUid))
        .delete();
  }

  /// The current friends of [uid], read from the `users/{uid}/friends`
  /// subcollection (see C-14 design D-1).
  Future<List<UserSummary>> loadFriends(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).collection('friends').get();

    return snapshot.docs.map((doc) => UserSummary.fromMap(doc.data())).toList();
  }

  /// The `username` field of `users/{uid}`, or empty string if missing.
  /// Used by `FriendsProvider` to denormalize the current user's username
  /// into requests/friendships it creates (see C-14 design D-6).
  Future<String> loadUsername(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['username'] as String? ?? '';
  }
}
