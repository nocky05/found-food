import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';
import 'package:found_food/shared/widgets/place_card.dart';
import 'package:found_food/features/profile/presentation/providers/profile_provider.dart';
import 'package:found_food/features/posts/presentation/providers/post_provider.dart';
import 'package:found_food/features/places/presentation/screens/place_details_screen.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  String _mapBudget(double? budget) {
    if (budget == null) return 'FCFA';
    if (budget < 5000) return 'FCFA';
    if (budget < 15000) return 'FCFA FCFA';
    return 'FCFA FCFA FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mes Favoris',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer2<ProfileProvider, PostProvider>(
        builder: (context, provider, postProvider, child) {
          if (provider.isLoading && provider.favoritePosts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.favoritePosts.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: AppDimensions.paddingMD),
            itemCount: provider.favoritePosts.length,
            itemBuilder: (context, index) {
              final post = provider.favoritePosts[index];
                return PlaceCard(
                  authorId: post.authorId,
                  authorName: post.authorName ?? 'Utilisateur',
                authorAvatarUrl: post.authorAvatar,
                isLiked: post.isLiked,
                isFavorited: true, // Par définition ici
                placeName: post.placeName ?? 'Lieu inconnu',
                location: post.placeAddress ?? 'Adresse inconnue',
                priceRange: _mapBudget(post.budgetSpent),
                distance: '${post.tripDuration ?? "?"} min',
                likes: post.likeCount,
                comments: post.commentCount,
                imageUrl: post.mediaUrls.isNotEmpty ? post.mediaUrls.first : '',
                foodImages: post.mediaUrls,
                onLike: () => postProvider.toggleLike(post),
                onFavorite: () => provider.toggleFavorite(post),
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
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: AppColors.textLight.withOpacity(0.5)),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            'Aucun favori pour le moment',
            style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          const Text(
            'Enregistrez les lieux que vous aimez pour les retrouver ici.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
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
