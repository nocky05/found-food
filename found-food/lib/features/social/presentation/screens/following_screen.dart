import 'package:flutter/material.dart';

class FollowingScreen extends StatelessWidget {
  final String userId;
  
  const FollowingScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnements', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: context.read<provider.FollowProvider>().fetchFollowingList(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final following = snapshot.data ?? [];
          if (following.isEmpty) {
            return const Center(child: Text('Aucun abonnement pour le moment'));
          }

          return ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              final data = following[index];
              final profile = data['profiles'] ?? {};
              final followingId = data['following_id'];
              
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
                trailing: _FollowButton(targetUserId: followingId),
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
        // Important: check status on build to ensure correct button state
        // Initial check is usually done in parent/profile, but good safety here
        
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
