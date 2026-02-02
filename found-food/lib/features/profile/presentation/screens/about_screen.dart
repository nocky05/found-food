import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.restaurant, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 16),
            const Text(
              'Found-Food',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Version 1.0.0'),
            const SizedBox(height: 40),
            const Text(
              'Found-Food est votre compagnon idéal pour découvrir et partager les meilleures expériences culinaires autour de vous.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Text(
              '© 2026 Found-Food Inc.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
