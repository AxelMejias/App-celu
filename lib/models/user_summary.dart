/// Immutable identity summary used for search results and friend list rows.
/// Denormalizes `username` alongside `uid` so rendering a list never needs an
/// extra lookup (see C-14 design D-3).
class UserSummary {
  const UserSummary({required this.uid, required this.username});

  factory UserSummary.fromMap(Map<String, dynamic> map) => UserSummary(
        uid: map['uid'] as String? ?? '',
        username: map['username'] as String? ?? '',
      );

  final String uid;
  final String username;

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'username': username,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSummary &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          username == other.username;

  @override
  int get hashCode => Object.hash(uid, username);
}
