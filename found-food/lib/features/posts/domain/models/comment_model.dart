class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      userName: json['profiles']?['full_name'] ?? json['profiles']?['username'],
      userAvatar: json['profiles']?['avatar_url'],
    );
  }
}
