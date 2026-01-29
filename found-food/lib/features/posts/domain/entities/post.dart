import 'package:found_food/features/places/domain/entities/place.dart';

class Post {
  final String id;
  final String userId;
  final Place place;
  final String description;
  final List<String> mediaUrls; // Photos or Video
  final bool isVideo;
  
  // User specific
  final double? personalBudget;
  final String? tips;
  
  // Social
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.place,
    required this.description,
    required this.mediaUrls,
    this.isVideo = false,
    this.personalBudget,
    this.tips,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });
}
