import 'package:flutter/material.dart';

class FollowingScreen extends StatelessWidget {
  final String userId;
  
  const FollowingScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Following Screen - User ID: $userId'),
      ),
    );
  }
}
