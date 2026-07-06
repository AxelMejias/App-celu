import 'package:flutter/foundation.dart';

import '../models/friend_request.dart';
import '../models/user_summary.dart';
import '../services/friends_service.dart';

/// Exposes the authenticated user's friendships (friends, incoming requests,
/// search results) to the widget tree as a [ChangeNotifier]. Mirrors the
/// injectable-dependency / `uid`-scoped pattern used by `ProfileProvider`
/// (see C-14 design D-6).
class FriendsProvider extends ChangeNotifier {
  FriendsProvider({FriendsService? friendsService, required this.uid})
      : _friendsService = friendsService ?? FriendsService();

  final FriendsService _friendsService;

  /// The authenticated user's uid, or `null` when signed out. Every mutating
  /// operation becomes a safe no-op in that case (see C-14 design D-7,
  /// mirrors C-13 design D-5 on `ProfileProvider.recordAnswer`).
  final String? uid;

  List<UserSummary> _friends = [];
  List<FriendRequest> _incomingRequests = [];
  List<UserSummary> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Cached once via `FriendsService.loadUsername` so `sendRequest`/`accept`
  // can denormalize it without coupling this provider to `ProfileProvider`
  // (see C-14 design D-6).
  String? _cachedUsername;

  List<UserSummary> get friends => _friends;
  List<FriendRequest> get incomingRequests => _incomingRequests;
  List<UserSummary> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFriends() async {
    final currentUid = uid;
    if (currentUid == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _friends = await _friendsService.loadFriends(currentUid);
    } catch (e) {
      _errorMessage = 'No se pudieron cargar los amigos. Intentá de nuevo';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadIncomingRequests() async {
    final currentUid = uid;
    if (currentUid == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _incomingRequests = await _friendsService.loadIncomingRequests(currentUid);
    } catch (e) {
      _errorMessage = 'No se pudieron cargar las solicitudes. Intentá de nuevo';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    final currentUid = uid;
    if (currentUid == null) return;

    try {
      final results = await _friendsService.searchUsers(query, excludeUid: currentUid);
      final friendUids = _friends.map((f) => f.uid).toSet();
      _searchResults = results.where((r) => !friendUids.contains(r.uid)).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No se pudo buscar usuarios. Intentá de nuevo';
      notifyListeners();
    }
  }

  Future<void> sendRequest(String targetUid) async {
    final currentUid = uid;
    if (currentUid == null) return;
    if (targetUid == currentUid) return;

    try {
      final username = await _myUsername(currentUid);
      await _friendsService.sendRequest(
        fromUid: currentUid,
        fromUsername: username,
        toUid: targetUid,
      );
    } catch (e) {
      _errorMessage = 'No se pudo enviar la solicitud. Intentá de nuevo';
      notifyListeners();
    }
  }

  Future<void> accept(FriendRequest request) async {
    final currentUid = uid;
    if (currentUid == null) return;

    try {
      final username = await _myUsername(currentUid);
      await _friendsService.acceptRequest(request: request, myUsername: username);
      _friends = [
        ..._friends,
        UserSummary(uid: request.fromUid, username: request.fromUsername),
      ];
      _incomingRequests = _incomingRequests.where((r) => r != request).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No se pudo aceptar la solicitud. Intentá de nuevo';
      notifyListeners();
    }
  }

  Future<void> reject(FriendRequest request) async {
    try {
      await _friendsService.rejectRequest(request);
      _incomingRequests = _incomingRequests.where((r) => r != request).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No se pudo rechazar la solicitud. Intentá de nuevo';
      notifyListeners();
    }
  }

  Future<String> _myUsername(String currentUid) async {
    return _cachedUsername ??= await _friendsService.loadUsername(currentUid);
  }
}
