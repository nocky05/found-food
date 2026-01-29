class Story {
  final String id;
  final String userId;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;
  final DateTime expiresAt;
  
  // Profile info (from view)
  final String? username;
  final String? fullName;
  final String? avatarUrl;

  Story({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    required this.expiresAt,
    this.username,
    this.fullName,
    this.avatarUrl,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      userId: json['user_id'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'] ?? 'image',
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class UserStories {
  final String userId;
  final String username;
  final String? avatarUrl;
  final List<Story> stories;

  UserStories({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.stories,
  });
}
