class Profile {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
