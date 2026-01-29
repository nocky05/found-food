import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:found_food/features/social/presentation/providers/follow_provider.dart';
import 'package:found_food/features/profile/presentation/providers/profile_provider.dart';
import 'package:found_food/features/profile/presentation/screens/public_profile_screen.dart';
class PlaceCard extends StatelessWidget {
  final String authorId; // New field
  final String authorName;
  final String? authorAvatarUrl;
  final bool isLiked;
  final bool isFavorited;
  final String placeName;
  final String location;
  final String priceRange;
  final String distance;
  final int likes;
  final int comments;
  final String imageUrl;
  final List<String> foodImages; 
  final VoidCallback onTap;
  final VoidCallback onDirections;
  final VoidCallback onViewDetails; 
  final VoidCallback? onLike;
  final VoidCallback? onFavorite;
  final VoidCallback? onComment;

  const PlaceCard({
    super.key,
    required this.authorId, // Requiring authorId
    required this.authorName,
    this.authorAvatarUrl,
    required this.isLiked,
    required this.isFavorited,
    required this.placeName,
    required this.location,
    required this.priceRange,
    required this.distance,
    required this.likes,
    required this.comments,
    required this.imageUrl,
    required this.foodImages,
    required this.onTap,
    required this.onDirections,
    required this.onViewDetails, 
    this.onLike,
    this.onFavorite,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    // Check follow status on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FollowProvider>().checkFollowStatus(authorId);
    });

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isCurrentUser = currentUserId == authorId;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // Header Auteur
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                   GestureDetector(
                    onTap: () {
                      if (!isCurrentUser) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PublicProfileScreen(userId: authorId),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                         Consumer<ProfileProvider>(
                          builder: (context, profileProvider, _) {
                            // If it's the current user, use the live profile avatar
                            // Otherwise, use the one from the post (authorAvatarUrl)
                            final avatarUrl = (isCurrentUser && profileProvider.userProfile?.avatarUrl != null)
                                ? profileProvider.userProfile!.avatarUrl
                                : authorAvatarUrl;
                            
                            return CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
                              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null || avatarUrl.isEmpty
                                  ? const Icon(Icons.person, size: 16, color: AppColors.primaryOrange)
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          authorName,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                   ),
                  const Spacer(),
                  // Follow Button
                  if (!isCurrentUser)
                  Consumer<FollowProvider>(
                    builder: (context, followProvider, _) {
                      final isFollowing = followProvider.isFollowing(authorId);
                      return GestureDetector(
                        onTap: () {
                          followProvider.toggleFollow(authorId);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isFollowing 
                                ? Colors.transparent 
                                : AppColors.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: isFollowing 
                                ? Border.all(color: AppColors.borderColor) 
                                : null,
                          ),
                          child: Text(
                            isFollowing ? 'Abonné' : 'Suivre',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isFollowing 
                                  ? AppColors.textSecondary 
                                  : AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Image principale
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: const Color(0xFFF5F5F5),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: 50,
                                  color: Color(0xFFDFE6E9),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 50,
                              color: Color(0xFFDFE6E9),
                            ),
                          ),
                  ),
                ),
                
                // Badge distance
                if (distance.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.distanceBadgeBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      distance,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.distanceBadgeText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du restaurant
                  Text(
                    placeName,
                    style: AppTypography.h3.copyWith(
                      fontSize: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Prix + Localisation
                  Row(
                    children: [
                      Text(
                        priceRange,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.priceColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF636E72),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Miniatures de plats
                  if (foodImages.isNotEmpty)
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: foodImages.length > 5 ? 5 : foodImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                foodImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFFF5F5F5),
                                    child: const Icon(
                                      Icons.fastfood,
                                      size: 18,
                                      color: Color(0xFFDFE6E9),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  
                  // Likes, Comments, View Menu
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onLike,
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isLiked ? AppColors.primaryOrange : const Color(0xFF95A5A6),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$likes',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onComment,
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: Color(0xFF95A5A6),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$comments',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onFavorite,
                        child: Icon(
                          isFavorited ? Icons.bookmark : Icons.bookmark_border,
                          size: 18,
                          color: isFavorited ? AppColors.primaryOrange : const Color(0xFF95A5A6),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: Color(0xFF95A5A6),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'View Menu',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Boutons Directions et View Details
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDirections,
                          icon: const Icon(Icons.directions, size: 16),
                          label: const Text('Directions', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonDirections,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onViewDetails,
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text('Details', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonCall,  // Garde la couleur jaune
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
