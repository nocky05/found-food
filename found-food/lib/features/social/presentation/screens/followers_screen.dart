import 'package:flutter/material.dart';

class FollowersScreen extends StatelessWidget {
  final String userId;
  
  const FollowersScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Followers Screen - User ID: $userId'),
      ),
    );
  }
}
