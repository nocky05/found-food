import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/places/presentation/screens/place_details_screen.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';
import 'package:found_food/features/profile/domain/models/profile_model.dart';
import 'package:found_food/features/profile/domain/repositories/profile_repository.dart';
import 'package:found_food/features/social/presentation/providers/follow_provider.dart';
import 'package:found_food/features/stories/presentation/providers/story_provider.dart';
import 'package:found_food/features/stories/presentation/screens/story_viewer_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:found_food/features/social/presentation/screens/followers_screen.dart';
import 'package:found_food/features/social/presentation/screens/following_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProfileRepository _profileRepository = ProfileRepository();
  
  Profile? _profile;
  List<Post> _userPosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Only posts for now
    _fetchData();
    
    // Check follow status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FollowProvider>().checkFollowStatus(widget.userId);
      context.read<FollowProvider>().fetchUserStats(widget.userId);
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _profileRepository.getProfile(widget.userId);
      final posts = await _profileRepository.getUserPosts(widget.userId);

      if (mounted) {
        setState(() {
          _profile = profile;
          _userPosts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Impossible de charger le profil";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          _profile?.username ?? 'Profil',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null 
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        _buildStatsSection(),
                        _buildActionButtons(),
                        _buildTabBar(),
                        _buildTabContent(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    if (_profile == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        children: [
           // Avatar avec bordure Story si active
          Consumer<StoryProvider>(
            builder: (context, storyProvider, child) {
              final hasActiveStory = storyProvider.hasActiveStory(_profile!.id);
              
              return GestureDetector(
                onTap: hasActiveStory 
                  ? () {
                      final index = storyProvider.userStories.indexWhere((s) => s.userId == _profile!.id);
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
                    }
                  : null, 
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: hasActiveStory
                        ? Border.all(color: AppColors.primaryOrange, width: 3)
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.lightPeach,
                    backgroundImage: (_profile!.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(_profile!.avatarUrl!)
                        : null,
                    child: (_profile!.avatarUrl == null || _profile!.avatarUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 50, color: AppColors.primaryOrange)
                        : null,
                  ),
                ),
              );
            }
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            _profile!.fullName ?? 'Utilisateur',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          if (_profile!.username != null)
            Text(
              '@${_profile!.username}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          const SizedBox(height: AppDimensions.spaceSM),
          if (_profile!.bio != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _profile!.bio!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer<FollowProvider>(
      builder: (context, followProvider, child) {
        final followers = followProvider.getFollowersCount(widget.userId);
        final following = followProvider.getFollowingCount(widget.userId);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMD),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('${_userPosts.length}', 'Posts'),
              _buildStatItem(
                '$followers', 
                'Followers',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FollowersScreen(userId: widget.userId)),
                  );
                },
              ),
              _buildStatItem(
                '$following', 
                'Following',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FollowingScreen(userId: widget.userId)),
                  );
                },
              ),
            ],
          ),
        );
      },
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
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<FollowProvider>(
      builder: (context, followProvider, child) {
        final isFollowing = followProvider.isFollowing(widget.userId);
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    followProvider.toggleFollow(widget.userId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.white : AppColors.primaryOrange,
                    foregroundColor: isFollowing ? AppColors.textPrimary : Colors.white,
                    side: isFollowing ? const BorderSide(color: AppColors.borderColor) : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(isFollowing ? 'Abonné' : 'Suivre'),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightPeach,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: IconButton(
                  onPressed: () {
                    // Message action placeholder
                  },
                  icon: const Icon(Icons.message_outlined, color: AppColors.primaryOrange),
                ),
              ),
            ],
          ),
        );
      },
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
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(icon: Icon(Icons.grid_on_outlined)),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPostGrid(),
        ],
      ),
    );
  }

  Widget _buildPostGrid() {
    if (_userPosts.isEmpty) {
      return const Center(child: Text('Aucune publication', style: TextStyle(color: AppColors.textSecondary)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
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
            color: Colors.grey[200],
            child: post.mediaUrls.isNotEmpty 
                ? Image.network(post.mediaUrls.first, fit: BoxFit.cover)
                : const Icon(Icons.image, color: Colors.grey),
          ),
        );
      },
    );
  }
}
