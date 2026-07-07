import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/friend_request.dart';
import '../models/user_summary.dart';
import '../providers/friends_provider.dart';
import '../theme/app_theme.dart';

/// Search users, review incoming friend requests, and list current friends
/// (see C-14 design D-8, D-7). Talks only to `FriendsProvider` — no direct
/// Firestore access.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<FriendsProvider>();
      provider.loadFriends();
      provider.loadIncomingRequests();
      provider.loadSentRequests();
    });
  }

  Future<void> _refresh(BuildContext context) async {
    final provider = context.read<FriendsProvider>();
    await provider.loadFriends();
    await provider.loadIncomingRequests();
    await provider.loadSentRequests();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.appBar,
        title: const Text(
          'Amigos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: ListView(
            padding: const EdgeInsets.all(24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildSearchField(context),
              const SizedBox(height: 8),
              if (provider.errorMessage != null) ...[
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
              ],
              ...provider.searchResults.map((user) => _buildSearchResultTile(context, user, provider)),
              const SizedBox(height: 24),
              if (provider.incomingRequests.isNotEmpty) ...[
                const Text(
                  'Solicitudes recibidas',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...provider.incomingRequests.map((request) => _buildRequestTile(context, request)),
                const SizedBox(height: 24),
              ],
              if (provider.sentRequests.isNotEmpty) ...[
                const Text(
                  'Solicitudes enviadas',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...provider.sentRequests.map((request) => _buildSentRequestTile(context, request)),
                const SizedBox(height: 24),
              ],
              const Text(
                'Mis amigos',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (provider.friends.isEmpty)
                const Text(
                  'Todavía no tenés amigos agregados.',
                  style: TextStyle(color: Colors.white54),
                )
              else
                ...provider.friends.map((friend) => _buildFriendTile(context, friend)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Buscar por username',
        hintStyle: TextStyle(color: Colors.white54),
      ),
      onChanged: (query) => context.read<FriendsProvider>().search(query),
    );
  }

  Widget _buildSearchResultTile(BuildContext context, UserSummary user, FriendsProvider provider) {
    final alreadySent = provider.sentRequestUids.contains(user.uid);
    return ListTile(
      tileColor: AppTheme.appBar,
      title: Text(user.username, style: const TextStyle(color: Colors.white)),
      trailing: TextButton(
        onPressed: alreadySent
            ? null
            : () => context
                .read<FriendsProvider>()
                .sendRequest(user.uid, toUsername: user.username),
        child: Text(alreadySent ? 'Enviada' : 'Agregar'),
      ),
    );
  }

  Widget _buildRequestTile(BuildContext context, FriendRequest request) {
    return ListTile(
      tileColor: AppTheme.appBar,
      title: Text(request.fromUsername, style: const TextStyle(color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => context.read<FriendsProvider>().accept(request),
            child: const Text('Aceptar'),
          ),
          TextButton(
            onPressed: () => context.read<FriendsProvider>().reject(request),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSentRequestTile(BuildContext context, FriendRequest request) {
    return ListTile(
      tileColor: AppTheme.appBar,
      title: Text(
        request.toUsername.isNotEmpty ? request.toUsername : request.toUid,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: const Text('Pendiente', style: TextStyle(color: Colors.white54)),
      trailing: TextButton(
        onPressed: () => context.read<FriendsProvider>().cancelSentRequest(request),
        child: const Text('Cancelar'),
      ),
    );
  }

  Widget _buildFriendTile(BuildContext context, UserSummary friend) {
    return ListTile(
      tileColor: AppTheme.appBar,
      title: Text(friend.username, style: const TextStyle(color: Colors.white)),
      onTap: () => Navigator.pushNamed(context, '/friend-profile', arguments: friend),
    );
  }
}
