import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:found_food/features/posts/presentation/providers/post_provider.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';
import 'package:found_food/features/stories/presentation/providers/story_provider.dart';
import 'package:found_food/features/stories/domain/models/story_model.dart';
import 'package:found_food/features/stories/presentation/screens/story_viewer_screen.dart';
import 'package:found_food/features/stories/presentation/screens/story_creator_screen.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/shared/widgets/story_circle.dart';
import 'package:found_food/shared/widgets/place_card.dart';
import 'package:found_food/features/places/presentation/screens/place_details_screen.dart';
import 'package:found_food/features/profile/presentation/providers/profile_provider.dart';
import 'package:found_food/features/social/presentation/screens/notifications_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Charger le flux au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchFeed();
      context.read<StoryProvider>().fetchStories();
    });
  }
  // Données de démonstration pour les stories
  final List<Map<String, dynamic>> _stories = [
    {'name': 'Sophie', 'imageUrl': '', 'hasStory': true},
    {'name': 'Marc', 'imageUrl': '', 'hasStory': true},
    {'name': 'Julie', 'imageUrl': '', 'hasStory': true},
    {'name': 'Pierre', 'imageUrl': '', 'hasStory': false},
    {'name': 'Emma', 'imageUrl': '', 'hasStory': true},
    {'name': 'Lucas', 'imageUrl': '', 'hasStory': false},
  ];

  // Données de démonstration pour les places
  final List<Map<String, dynamic>> _places = [
    {
      'name': 'Le Petit Bistro',
      'location': 'Montmartre, Paris',
      'priceRange': 'FCFA FCFA',
      'distance': '500m',
      'likes': 42,
      'comments': 8,
      'imageUrl': '',
      'foodImages': ['', '', '', '', ''],
    },
    {
      'name': 'Sushi Paradise',
      'location': 'Le Marais, Paris',
      'priceRange': 'FCFA FCFA FCFA',
      'distance': '1.2km',
      'likes': 128,
      'comments': 23,
      'imageUrl': '',
      'foodImages': ['', '', '', '', ''],
    },
    {
      'name': 'Café des Arts',
      'location': 'Latin Quarter, Paris',
      'priceRange': 'FCFA',
      'distance': '800m',
      'likes': 67,
      'comments': 12,
      'imageUrl': '',
      'foodImages': ['', '', '', ''],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Stories Section
            _buildStoriesSection(),
            
            // Feed List
            Expanded(
              child: Consumer2<PostProvider, ProfileProvider>(
                builder: (context, postProvider, profileProvider, _) {
                  if (postProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (postProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(postProvider.error!, style: const TextStyle(color: Colors.red)),
                          TextButton(
                            onPressed: () => postProvider.fetchFeed(),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (postProvider.feedPosts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restaurant_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun post pour le moment.\nSoyez le premier à partager !',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => postProvider.fetchFeed(),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: postProvider.feedPosts.length,
                      itemBuilder: (context, index) {
                        final post = postProvider.feedPosts[index];
                        return PlaceCard(
                          authorId: post.authorId,
                          authorName: post.authorName ?? 'Utilisateur',
                          authorAvatarUrl: post.authorAvatar,
                          isLiked: post.isLiked,
                          isFavorited: post.isFavorited,
                          placeName: post.placeName ?? 'Lieu inconnu',
                          location: post.placeAddress ?? 'Adresse inconnue',
                          priceRange: _mapBudget(post.budgetSpent),
                          distance: (post.tripDuration != null && post.tripDuration! > 0) ? '${post.tripDuration} min' : '',
                          likes: post.likeCount,
                          comments: post.commentCount,
                          imageUrl: post.mediaUrls.isNotEmpty ? post.mediaUrls.first : '',
                          foodImages: post.mediaUrls,
                          onLike: () => postProvider.toggleLike(post),
                          onFavorite: () => profileProvider.toggleFavorite(post),
                          onComment: () => _showCommentModal(context, post),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaceDetailsScreen(post: post),
                              ),
                            );
                          },
                          onDirections: () {
                            Navigator.pushNamed(context, '/map');
                          },
                          onViewDetails: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaceDetailsScreen(post: post),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: 10,  // Réduit de 12 à 10
      ),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Icon
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search navigation if needed, 
              // but currently handled by the bottom navigation bar.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Utilisez l\'onglet Recherche en bas pour chercher un lieu.')),
              );
            },
          ),
          
          // Logo/Title
          Expanded(
            child: const Center(
              child: Text(
                'Found-Food',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Notifications Icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD63031),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesSection() {
    return Consumer2<StoryProvider, ProfileProvider>(
      builder: (context, storyProvider, profileProvider, _) {
        if (storyProvider.isLoading && storyProvider.userStories.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          height: 120,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
            itemCount: storyProvider.userStories.length + 1, // +1 for "Add Story"
            itemBuilder: (context, index) {
              if (index == 0) {
                // "Ma Story" - Toujours afficher le bouton "+"
                final hasStories = storyProvider.currentUserHasStories;
                return StoryCircle(
                  imageUrl: profileProvider.userProfile?.avatarUrl ?? '',
                  name: 'Ma Story',
                  hasStory: hasStories,
                  showAddButton: true, // Toujours afficher le bouton "+"
                  onTap: () {
                    // Cliquer sur le cercle = voir ses stories (si on en a)
                    if (hasStories) {
                      final currentUserStories = storyProvider.currentUserStories;
                      if (currentUserStories != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryViewerScreen(
                              userStoriesList: [currentUserStories],
                              initialUserIndex: 0,
                            ),
                          ),
                        );
                      }
                    } else {
                      // Si pas de stories, le bouton "+" est là pour en créer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StoryCreatorScreen()),
                      ).then((_) {
                        storyProvider.fetchStories();
                      });
                    }
                  },
                  onAddTap: () {
                    // Cliquer sur le "+" = créer une nouvelle story
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StoryCreatorScreen()),
                    ).then((_) {
                      storyProvider.fetchStories();
                    });
                  },
                );
              }

              // Stories des autres utilisateurs (exclure l'utilisateur actuel s'il apparaît dans la liste)
              final currentUserId = Supabase.instance.client.auth.currentUser?.id;
              final userStories = storyProvider.userStories[index - 1];
              
              // Ne pas afficher l'utilisateur actuel deux fois
              if (userStories.userId == currentUserId) {
                return const SizedBox.shrink();
              }

              return StoryCircle(
                imageUrl: userStories.avatarUrl ?? '',
                name: userStories.username,
                hasStory: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryViewerScreen(
                        userStoriesList: storyProvider.userStories,
                        initialUserIndex: index - 1,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _mapBudget(double? budget) {
    if (budget == null || budget == 0) return 'Budget non spécifié';
    // Format simple avec séparateur de milliers si possible, sinon brut
    final amount = budget.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    );
    return 'Budget: $amount FCFA';
  }

  void _showCommentModal(BuildContext context, Post post) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Commenter ${post.placeName}',
                style: AppTypography.h3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Votre avis...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primaryOrange),
                    onPressed: () async {
                      if (controller.text.trim().isNotEmpty) {
                        await context.read<PostProvider>().addComment(
                          post.id,
                          controller.text.trim(),
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
