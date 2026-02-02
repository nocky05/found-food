import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:found_food/features/social/presentation/providers/follow_provider.dart';
import 'package:found_food/features/profile/presentation/screens/public_profile_screen.dart';
import 'package:found_food/features/profile/presentation/screens/profile_screen.dart';

class FollowingScreen extends StatelessWidget {
  final String userId;
  
  const FollowingScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnements', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: context.read<FollowProvider>().fetchFollowingList(userId),
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
                trailing: followingId == currentUserId 
                   ? null 
                   : _FollowButton(targetUserId: followingId),
                onTap: () {
                  if (followingId == currentUserId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicProfileScreen(userId: followingId),
                      ),
                    );
                  }
                },
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
    return Consumer<FollowProvider>(
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
