import 'package:flutter/material.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final String placeId;
  
  const PlaceDetailsScreen({
    super.key,
    required this.placeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Place Details Screen - ID: $placeId'),
      ),
    );
  }
}
