import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/posts/domain/models/post_model.dart';
import 'package:found_food/features/posts/presentation/providers/post_provider.dart';
import 'package:found_food/features/places/domain/repositories/place_repository.dart';
import 'package:provider/provider.dart';
import 'package:found_food/features/profile/presentation/providers/profile_provider.dart';
import 'package:found_food/features/social/presentation/providers/follow_provider.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Post post;
  
  const PlaceDetailsScreen({
    super.key,
    required this.post,
  });

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  Place? _placeDetails;
  bool _isLoadingPlace = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchComments(widget.post.id);
      _loadPlaceDetails();
    });
  }

  Future<void> _loadPlaceDetails() async {
    try {
      final place = await PlaceRepository().getPlaceById(widget.post.placeId);
      if (mounted) {
        setState(() {
          _placeDetails = place;
          _isLoadingPlace = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPlace = false);
      print("Erreur chargement détails lieu: $e");
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmittingComment = true);
    try {
      await context.read<PostProvider>().addComment(
        widget.post.id, 
        _commentController.text.trim()
      );
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commentaire ajouté !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'ajout du commentaire')),
      );
    } finally {
      setState(() => _isSubmittingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorSection(context),
                  const SizedBox(height: AppDimensions.spaceMD),
                  _buildTitleSection(),
                  const SizedBox(height: AppDimensions.spaceMD),
                  _buildQuickInfoCards(),
                  const SizedBox(height: AppDimensions.spaceLG),
                  _buildSectionTitle('L\'Expérience'),
                  const SizedBox(height: AppDimensions.spaceSM),
                  Text(
                    widget.post.content ?? 'Pas de description.',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  _buildBudgetBreakdown(),
                  const SizedBox(height: AppDimensions.spaceLG),
                  _buildSectionTitle('Informations sur le lieu'),
                  const SizedBox(height: AppDimensions.spaceSM),
                  _buildPlaceDetailsCard(context),
                  const SizedBox(height: AppDimensions.spaceLG),
                  _buildSectionTitle('Trajet & Accès'),
                  const SizedBox(height: AppDimensions.spaceSM),
                  _buildDetailedTripInfo(),
                  const SizedBox(height: AppDimensions.spaceLG),
                  _buildMediaGallery(context),
                  const SizedBox(height: AppDimensions.spaceLG),
                  _buildSectionTitle('Commentaires'),
                  const SizedBox(height: AppDimensions.spaceSM),
                  _buildCommentInput(),
                  const SizedBox(height: 16),
                  _buildCommentsList(),
                  const SizedBox(height: 100), // Espace pour le bouton flottant
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primaryOrange,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.post.mediaUrls.isNotEmpty ? widget.post.mediaUrls.first : 'https://picsum.photos/800/600',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildAuthorSection(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        // Retrouver le post à jour dans le provider si possible
        final currentPost = provider.feedPosts.firstWhere(
          (p) => p.id == widget.post.id, 
          orElse: () => widget.post
        );

        // Check follow status
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<FollowProvider>().checkFollowStatus(currentPost.authorId);
        });

        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: currentPost.authorAvatar != null ? NetworkImage(currentPost.authorAvatar!) : null,
              child: currentPost.authorAvatar == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      currentPost.authorName ?? 'Utilisateur',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    // Follow Button
                    Consumer<FollowProvider>(
                      builder: (context, followProvider, _) {
                        final isFollowing = followProvider.isFollowing(currentPost.authorId);
                        return GestureDetector(
                          onTap: () {
                            followProvider.toggleFollow(currentPost.authorId);
                          },
                          child: Text(
                            isFollowing ? '• Abonné' : '• Suivre',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isFollowing 
                                  ? AppColors.textSecondary 
                                  : AppColors.primaryOrange,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  'Posté le ${currentPost.createdAt.day}/${currentPost.createdAt.month}/${currentPost.createdAt.year}',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                IconButton(
                  onPressed: () => provider.toggleLike(currentPost),
                  icon: Icon(
                    currentPost.isLiked ? Icons.favorite : Icons.favorite_border, 
                    color: AppColors.primaryOrange
                  ),
                ),
                Text(
                  '${currentPost.likeCount}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                final isFav = profileProvider.favoritePosts.any((p) => p.id == widget.post.id);
                return Column(
                  children: [
                    IconButton(
                      onPressed: () => profileProvider.toggleFavorite(currentPost),
                      icon: Icon(
                        isFav ? Icons.bookmark : Icons.bookmark_border, 
                        color: AppColors.primaryOrange
                      ),
                    ),
                    const Text(
                      'Favori',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.post.placeName ?? 'Lieu inconnu',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary, fontSize: 24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primaryOrange, size: 16),
            const SizedBox(width: 4),
            Text(
              widget.post.placeAddress ?? 'Adresse non spécifiée',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInfoCards() {
    return Row(
      children: [
        _infoCard(
          Icons.payments_outlined, 
          'Budget Moyen', 
          _placeDetails?.budgetRange ?? (_placeDetails == null && _isLoadingPlace ? '...' : 'Non spécifié')
        ),
        const SizedBox(width: AppDimensions.spaceSM),
        _infoCard(
          Icons.directions_walk, 
          'Durée Trajet', 
          (widget.post.tripDuration != null && widget.post.tripDuration! > 0)
              ? '${widget.post.tripDuration} min'
              : 'Non spécifié'
        ),
        const SizedBox(width: AppDimensions.spaceSM),
        _infoCard(
          Icons.commute, 
          'Moyen', 
          widget.post.transportMode ?? 'Non spécifié'
        ),
      ],
    );
  }


  Widget _infoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryOrange, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetBreakdown() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Budget dépensé sur place', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Montant indiqué par l\'auteur', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          Text(
            '${widget.post.budgetSpent?.toInt() ?? 0} FCFA',
            style: AppTypography.h3.copyWith(color: AppColors.primaryOrange, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.map_outlined, 'Adresse', widget.post.placeAddress ?? 'Non spécifiée'),
          const Divider(height: 24),
          _buildDetailRow(Icons.category_outlined, 'Catégorie', 'Restaurant'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isAction = false}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textLight, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            Text(value, style: TextStyle(fontSize: 13, color: isAction ? AppColors.primaryOrange : AppColors.textPrimary, fontWeight: isAction ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
        if (isAction) const Spacer(),
        if (isAction) const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryOrange),
      ],
    );
  }

  Widget _buildDetailedTripInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.commute_outlined, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text('Transport : ${widget.post.transportMode ?? "Non spécifié"}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('Coût : ${widget.post.tripCost?.toInt() ?? 0} FCFA', style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMediaGallery(BuildContext context) {
    if (widget.post.mediaUrls.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Photos de l\'expérience'),
        const SizedBox(height: AppDimensions.spaceSM),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.post.mediaUrls.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: AppDimensions.spaceSM),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  image: DecorationImage(
                    image: NetworkImage(widget.post.mediaUrls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Ajouter un commentaire...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              maxLines: null,
            ),
          ),
          _isSubmittingComment 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : IconButton(
                onPressed: _submitComment,
                icon: const Icon(Icons.send, color: AppColors.primaryOrange),
              ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                 Navigator.pushNamed(context, '/map');
              },
              icon: const Icon(Icons.navigation_outlined),
              label: const Text('Itinéraire'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Container(
            decoration: BoxDecoration(
              color: AppColors.buttonCall,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu bientôt disponible...')),
                );
              },
              icon: const Icon(Icons.restaurant_menu, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        final comments = provider.currentPostComments;
        if (comments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Aucun commentaire pour le moment.',
                style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (context, index) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: comment.userAvatar != null ? NetworkImage(comment.userAvatar!) : null,
                  child: comment.userAvatar == null ? const Icon(Icons.person, size: 20) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            comment.userName ?? 'Utilisateur',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${comment.createdAt.day}/${comment.createdAt.month}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
