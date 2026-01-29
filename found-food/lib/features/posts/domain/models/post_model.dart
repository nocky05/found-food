import 'package:uuid/uuid.dart';

class Place {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? category;
  final String? budgetRange;
  final String? menuUrl;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  Place({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.category,
    this.budgetRange,
    this.menuUrl,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      category: json['category'],
      budgetRange: json['budget_range'],
      menuUrl: json['menu_url'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'category': category,
      'budget_range': budgetRange,
      'menu_url': menuUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Post {
  final String id;
  final String authorId;
  final String placeId;
  final String? content;
  final double? budgetSpent;
  final double? tripCost;
  final int? tripDuration;
  final String? transportMode;
  final DateTime createdAt;
  
  // Extra fields for UI mapping (Joined data)
  final String? authorName;
  final String? authorAvatar;
  final String? placeName;
  final String? placeAddress;
  final List<String> mediaUrls;
  int likeCount;
  int commentCount;
  bool isLiked;
  bool isFavorited;

  Post({
    required this.id,
    required this.authorId,
    required this.placeId,
    this.content,
    this.budgetSpent,
    this.tripCost,
    this.tripDuration,
    this.transportMode,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
    this.placeName,
    this.placeAddress,
    this.mediaUrls = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isFavorited = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final media = json['post_media'] as List?;
    
    // Extract interaction counts from JSON if available (using Supabase column naming convention)
    final likesCount = json['likes_count'] ?? 0;
    final commentsCount = json['comments_count'] ?? 0;
    final userLiked = json['is_liked'] ?? false;
    final userFavorited = json['is_favorited'] ?? false;

    return Post(
      id: json['id'],
      authorId: json['author_id'],
      placeId: json['place_id'],
      content: json['content'],
      budgetSpent: json['budget_spent']?.toDouble(),
      tripCost: json['trip_cost']?.toDouble(),
      tripDuration: json['trip_duration'],
      transportMode: json['transport_mode'],
      createdAt: DateTime.parse(json['created_at']),
      authorName: json['profiles']?['full_name'] ?? json['profiles']?['username'],
      authorAvatar: json['profiles']?['avatar_url'],
      placeName: json['places']?['name'],
      placeAddress: json['places']?['address'],
      mediaUrls: media != null ? media.map((m) => m['url'] as String).toList() : [],
      likeCount: likesCount,
      commentCount: commentsCount,
      isLiked: userLiked,
      isFavorited: userFavorited,
    );
  }
}
