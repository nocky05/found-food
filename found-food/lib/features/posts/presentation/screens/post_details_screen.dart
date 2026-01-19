import 'package:flutter/material.dart';

class PostDetailsScreen extends StatelessWidget {
  final String postId;
  
  const PostDetailsScreen({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Post Details Screen - ID: $postId'),
      ),
    );
  }
}
