import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:found_food/features/profile/presentation/screens/settings_screen.dart';
import 'package:found_food/features/profile/presentation/providers/profile_provider.dart';
import 'package:found_food/features/places/presentation/screens/place_details_screen.dart';
import 'package:found_food/features/stories/presentation/providers/story_provider.dart';
import 'package:found_food/features/stories/presentation/screens/story_creator_screen.dart';
import 'package:found_food/features/stories/presentation/screens/story_viewer_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:found_food/features/social/presentation/providers/follow_provider.dart';
import 'package:found_food/features/social/presentation/screens/followers_screen.dart';
import 'package:found_food/features/social/presentation/screens/following_screen.dart';
import 'package:found_food/features/social/presentation/screens/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        context.read<FollowProvider>().fetchUserStats(userId);
      }
    });
  }

  // ... (dispose and other methods remain)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Consumer2<ProfileProvider, FollowProvider>( // Use Consumer2
        builder: (context, provider, followProvider, child) {
          if (provider.isLoading && provider.userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.userProfile == null) {
            return Center(child: Text(provider.error!));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchProfileData();
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId != null) {
                await followProvider.fetchUserStats(userId);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileHeader(provider),
                  _buildStatsSection(provider, followProvider), // Pass followProvider
                  _buildActionButtons(),
                  _buildTabBar(),
                  _buildTabContent(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.cardColor,
      elevation: 0,
      title: Text(
        'Mon Profil',
        style: AppTypography.h3.copyWith(
          color: theme.textTheme.bodyLarge?.color
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings_outlined, 
            color: theme.textTheme.bodyLarge?.color
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(ProfileProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profile = provider.userProfile;

    if (profile == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        children: [
          // Avatar avec bordure Story si active
          Consumer<StoryProvider>(
            builder: (context, storyProvider, child) {
              final hasActiveStory = storyProvider.hasActiveStory(profile.id);
              
              return GestureDetector(
                  onTap: () {
                    if (hasActiveStory) {
                      final index = storyProvider.userStories.indexWhere((s) => s.userId == profile.id);
                      if (index != -1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryViewerScreen(
                              userStoriesList: storyProvider.userStories,
                              initialUserIndex: index,
                            ),
                          ),
                        );
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StoryCreatorScreen(),
                        ),
                      );
                    }
                  },
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: hasActiveStory
                            ? Border.all(color: AppColors.primaryOrange, width: 3)
                            : null,
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: isDark ? Colors.grey[900] : AppColors.lightPeach,
                        backgroundImage: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                            ? NetworkImage(profile.avatarUrl!)
                            : null,
                        child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                            ? Icon(
                                Icons.person, 
                                size: 50, 
                                color: isDark ? Colors.white24 : AppColors.primaryOrange
                              )
                            : null,
                      ),
                    ),
                    if (!hasActiveStory)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).cardColor, width: 3),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            profile.fullName ?? 'Utilisateur',
            style: AppTypography.h3.copyWith(color: theme.textTheme.bodyLarge?.color),
          ),
          if (profile.username != null)
            Text(
              '@${profile.username}',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? Colors.white54 : AppColors.textSecondary
              ),
            ),
          const SizedBox(height: AppDimensions.spaceSM),
          if (profile.bio != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                profile.bio!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textPrimary
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ProfileProvider profileProvider, FollowProvider followProvider) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final followers = userId != null ? followProvider.getFollowersCount(userId) : 0;
    final following = userId != null ? followProvider.getFollowingCount(userId) : 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('${profileProvider.userPosts.length}', 'Posts'),
          _buildStatItem(
            '$followers', 
            'Followers',
            onTap: userId != null ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FollowersScreen(userId: userId)),
              );
            } : null,
          ),
          _buildStatItem(
            '$following', 
            'Following',
            onTap: userId != null ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FollowingScreen(userId: userId)),
              );
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.h4.copyWith(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white38 
                  : AppColors.textSecondary
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Modifier le profil'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.spaceLG),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryOrange,
        labelColor: AppColors.primaryOrange,
        unselectedLabelColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white38 
            : AppColors.textSecondary,
        tabs: const [
          Tab(icon: Icon(Icons.grid_on_outlined)),
          Tab(icon: Icon(Icons.bookmark_outline)),
        ],
      ),
    );
  }

  Widget _buildTabContent(ProfileProvider provider) {
    return SizedBox(
      height: 400, 
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPostGrid(provider),
          _buildSavedGrid(provider),
        ],
      ),
    );
  }

  Widget _buildPostGrid(ProfileProvider provider) {
    if (provider.userPosts.isEmpty) {
      return const Center(child: Text('Aucune publication', style: TextStyle(color: AppColors.textSecondary)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: provider.userPosts.length,
      itemBuilder: (context, index) {
        final post = provider.userPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailsScreen(post: post),
              ),
            );
          },
          onLongPress: () => _showDeleteConfirmation(context, post.id),
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[900] 
                : Colors.grey[200],
            child: post.mediaUrls.isNotEmpty 
                ? Image.network(post.mediaUrls.first, fit: BoxFit.cover)
                : Icon(
                    Icons.image, 
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white10 
                        : Colors.grey
                  ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la publication ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<ProfileProvider>().deletePost(postId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Publication supprimée' : 'Erreur lors de la suppression'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.errorColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedGrid(ProfileProvider provider) {
    if (provider.favoritePosts.isEmpty) {
      return const Center(
        child: Text(
          'Aucun lieu enregistré',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: provider.favoritePosts.length,
      itemBuilder: (context, index) {
        final post = provider.favoritePosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailsScreen(post: post),
              ),
            );
          },
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[900] 
                : Colors.grey[200],
            child: post.mediaUrls.isNotEmpty 
                ? Image.network(post.mediaUrls.first, fit: BoxFit.cover)
                : Icon(
                    Icons.bookmark, 
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white10 
                        : Colors.grey
                  ),
          ),
        );
      },
    );
  }
}
