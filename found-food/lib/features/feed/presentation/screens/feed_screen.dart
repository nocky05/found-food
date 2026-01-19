import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/shared/widgets/story_circle.dart';
import 'package:found_food/shared/widgets/place_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Données de démonstration pour les stories
  final List<Map<String, dynamic>> _stories = [
    {'name': 'Sophie', 'imageUrl': '', 'hasStory': true},
    {'name': 'Marc', 'imageUrl': '', 'hasStory': true},
    {'name': 'Julie', 'imageUrl': '', 'hasStory': true},
    {'name': 'Pierre', 'imageUrl': '', 'hasStory': false},
    {'name': 'Emma', 'imageUrl': '', 'hasStory': true},
    {'name': 'Lucas', 'imageUrl': '', 'hasStory': false},
  ];

  // Données de démonstration pour les places
  final List<Map<String, dynamic>> _places = [
    {
      'name': 'Le Petit Bistro',
      'location': 'Montmartre, Paris',
      'priceRange': 'FCFA FCFA',
      'distance': '500m',
      'likes': 42,
      'comments': 8,
      'imageUrl': '',
      'foodImages': ['', '', '', '', ''],
    },
    {
      'name': 'Sushi Paradise',
      'location': 'Le Marais, Paris',
      'priceRange': 'FCFA FCFA FCFA',
      'distance': '1.2km',
      'likes': 128,
      'comments': 23,
      'imageUrl': '',
      'foodImages': ['', '', '', '', ''],
    },
    {
      'name': 'Café des Arts',
      'location': 'Latin Quarter, Paris',
      'priceRange': 'FCFA',
      'distance': '800m',
      'likes': 67,
      'comments': 12,
      'imageUrl': '',
      'foodImages': ['', '', '', ''],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Stories Section
            _buildStoriesSection(),
            
            // Feed List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),  // Petit padding pour l'espacement
                itemCount: _places.length,
                itemBuilder: (context, index) {
                  final place = _places[index];
                  return PlaceCard(
                    placeName: place['name'],
                    location: place['location'],
                    priceRange: place['priceRange'],
                    distance: place['distance'],
                    likes: place['likes'],
                    comments: place['comments'],
                    imageUrl: place['imageUrl'],
                    foodImages: List<String>.from(place['foodImages']),
                    onTap: () {
                      // TODO: Navigate to place details
                    },
                    onDirections: () {
                      // TODO: Open maps with place location
                    },
                    onViewDetails: () {
                      // TODO: Navigate to place details screen
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: 10,  // Réduit de 12 à 10
      ),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Icon
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to search
            },
          ),
          
          // Logo/Title
          const Text(
            'Found-Food',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          // Notifications Icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  // TODO: Navigate to notifications
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD63031),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesSection() {
    return Container(
      height: 120,  // Augmenté de 110 à 120 pour éviter overflow du texte
      padding: const EdgeInsets.symmetric(vertical: 10),  // Réduit de 12 à 10
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return StoryCircle(
            imageUrl: story['imageUrl'],
            name: story['name'],
            hasStory: story['hasStory'],
            onTap: () {
              // TODO: Open story viewer
            },
          );
        },
      ),
    );
  }
}
