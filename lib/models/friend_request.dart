/// Deterministic id for a friend request between [fromUid] and [toUid].
/// Makes resending the same request idempotent (see C-14 design D-4).
String requestId(String fromUid, String toUid) => '${fromUid}_$toUid';

/// Immutable pending (or resolved, transiently) friend request, stored at
/// `friendRequests/{fromUid}_{toUid}` (see C-14 design D-4). `fromUsername`
/// is denormalized so rendering the incoming-requests inbox needs no extra
/// lookup (see C-14 design D-3).
class FriendRequest {
  const FriendRequest({
    required this.fromUid,
    required this.fromUsername,
    required this.toUid,
    this.toUsername = '',
    this.status = 'pending',
    this.createdAt,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map, {String? id}) => FriendRequest(
        fromUid: map['fromUid'] as String? ?? '',
        fromUsername: map['fromUsername'] as String? ?? '',
        toUid: map['toUid'] as String? ?? '',
        // Docs anteriores a C-17 no tienen toUsername — cae a '' y la UI
        // muestra el uid como fallback.
        toUsername: map['toUsername'] as String? ?? '',
        status: map['status'] as String? ?? 'pending',
        createdAt: _parseCreatedAt(map['createdAt']),
      );

  /// `createdAt` arrives as a Firestore `Timestamp` in production and as a
  /// plain `DateTime` (or absent) in tests; avoid importing `cloud_firestore`
  /// here by duck-typing the `toDate()` conversion (models stay pure/plain).
  static DateTime? _parseCreatedAt(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }

  final String fromUid;
  final String fromUsername;
  final String toUid;
  final String toUsername;
  final String status;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'fromUid': fromUid,
        'fromUsername': fromUsername,
        'toUid': toUid,
        'toUsername': toUsername,
        'status': status,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendRequest &&
          runtimeType == other.runtimeType &&
          fromUid == other.fromUid &&
          fromUsername == other.fromUsername &&
          toUid == other.toUid &&
          toUsername == other.toUsername &&
          status == other.status;

  @override
  int get hashCode => Object.hash(fromUid, fromUsername, toUid, toUsername, status);
}
