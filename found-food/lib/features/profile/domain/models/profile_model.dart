class Profile {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final DateTime updatedAt;
  final bool isDarkMode;
  final bool notificationsEnabled;

  Profile({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    required this.updatedAt,
    this.isDarkMode = false,
    this.notificationsEnabled = true,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      isDarkMode: json['is_dark_mode'] ?? false,
      notificationsEnabled: json['notifications_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_dark_mode': isDarkMode,
      'notifications_enabled': notificationsEnabled,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
