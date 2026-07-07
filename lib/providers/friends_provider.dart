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
  List<FriendRequest> _sentRequests = [];
  final Set<String> _sentRequestUids = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Cached once via `FriendsService.loadUsername` so `sendRequest`/`accept`
  // can denormalize it without coupling this provider to `ProfileProvider`
  // (see C-14 design D-6).
  String? _cachedUsername;

  List<UserSummary> get friends => _friends;
  List<FriendRequest> get incomingRequests => _incomingRequests;
  List<UserSummary> get searchResults => _searchResults;

  /// Solicitudes enviadas pendientes, persistidas en Firestore y cargadas
  /// vía `loadSentRequests()` (see C-17 design D-2).
  List<FriendRequest> get sentRequests => _sentRequests;

  /// Uids con una solicitud enviada pendiente: unión de lo persistido
  /// (`sentRequests`, cargado desde Firestore) con lo agregado en esta
  /// sesión por `sendRequest`, para que un usuario aparezca "Enviada" tanto
  /// tras reiniciar la app como inmediatamente después de tocar "Agregar"
  /// (see C-17 design D-2).
  Set<String> get sentRequestUids =>
      {..._sentRequests.map((r) => r.toUid), ..._sentRequestUids};
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

  Future<void> sendRequest(String targetUid, {String toUsername = ''}) async {
    final currentUid = uid;
    if (currentUid == null) return;
    if (targetUid == currentUid) return;

    _errorMessage = null;
    try {
      final username = await _myUsername(currentUid);
      await _friendsService.sendRequest(
        fromUid: currentUid,
        fromUsername: username,
        toUid: targetUid,
        toUsername: toUsername,
      );
      _sentRequestUids.add(targetUid);
      notifyListeners();
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

  /// Loads the pending requests originated by the authenticated user (see
  /// C-17 design D-2). No-op without an authenticated user.
  Future<void> loadSentRequests() async {
    final currentUid = uid;
    if (currentUid == null) return;

    try {
      _sentRequests = await _friendsService.loadSentRequests(currentUid);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No se pudieron cargar las solicitudes enviadas. Intentá de nuevo';
      notifyListeners();
    }
  }

  /// Cancels [request], a pending request originated by the authenticated
  /// user: deletes its document (reusing `FriendsService.rejectRequest`, see
  /// C-17 design D-4) and removes it from `sentRequests`/`sentRequestUids`.
  /// No-op without an authenticated user.
  Future<void> cancelSentRequest(FriendRequest request) async {
    if (uid == null) return;

    try {
      await _friendsService.rejectRequest(request);
      _sentRequests = _sentRequests.where((r) => r != request).toList();
      _sentRequestUids.remove(request.toUid);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'No se pudo cancelar la solicitud. Intentá de nuevo';
      notifyListeners();
    }
  }

  Future<String> _myUsername(String currentUid) async {
    return _cachedUsername ??= await _friendsService.loadUsername(currentUid);
  }
}
