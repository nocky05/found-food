import 'package:flutter/material.dart';

class FollowersScreen extends StatelessWidget {
  final String userId;
  
  const FollowersScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnés', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: context.read<provider.FollowProvider>().fetchFollowersList(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final followers = snapshot.data ?? [];
          if (followers.isEmpty) {
            return const Center(child: Text('Aucun abonné pour le moment'));
          }

          return ListView.builder(
            itemCount: followers.length,
            itemBuilder: (context, index) {
              final data = followers[index];
              final profile = data['profiles'] ?? {};
              final followerId = data['follower_id'];
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (profile['avatar_url'] != null && profile['avatar_url'].isNotEmpty)
                      ? NetworkImage(profile['avatar_url'])
                      : null,
                  child: (profile['avatar_url'] == null || profile['avatar_url'].isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(profile['full_name'] ?? 'Utilisateur'),
                subtitle: Text('@${profile['username'] ?? ""}'),
                trailing: userId == Supabase.instance.client.auth.currentUser?.id 
                   ? null // On ne se suit pas soi-même dans sa propre liste
                   : _FollowButton(targetUserId: followerId), // Bouton pour suivre en retour
              );
            },
          );
        },
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final String targetUserId;
  const _FollowButton({required this.targetUserId});

  @override
  Widget build(BuildContext context) {
    return Consumer<provider.FollowProvider>(
      builder: (context, followProvider, _) {
        final isFollowing = followProvider.isFollowing(targetUserId);
        return ElevatedButton(
          onPressed: () => followProvider.toggleFollow(targetUserId),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey[300] : const Color(0xFFFF6B6B),
            foregroundColor: isFollowing ? Colors.black : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(isFollowing ? 'Abonné' : 'Suivre'),
        );
      },
    );
  }
}
