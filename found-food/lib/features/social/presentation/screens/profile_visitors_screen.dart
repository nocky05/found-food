import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_dimensions.dart';
import 'package:found_food/core/theme/app_typography.dart';

class ProfileVisitorsScreen extends StatelessWidget {
  const ProfileVisitorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Données fictives pour les visiteurs
    final List<Map<String, String>> visitors = [
      {'name': 'Jean Dupont', 'time': 'Il y a 2 min', 'avatar': 'https://i.pravatar.cc/150?u=jean'},
      {'name': 'Marie Curie', 'time': 'Il y a 15 min', 'avatar': 'https://i.pravatar.cc/150?u=marie'},
      {'name': 'Paul Martin', 'time': 'Il y a 1h', 'avatar': 'https://i.pravatar.cc/150?u=paul'},
      {'name': 'Clara Woods', 'time': 'Il y a 3h', 'avatar': 'https://i.pravatar.cc/150?u=clara'},
      {'name': 'Alex Smith', 'time': 'Hier', 'avatar': 'https://i.pravatar.cc/150?u=alex'},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Visiteurs récents',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Text(
              'Ces personnes ont consulté votre profil récemment.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: visitors.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 70,
                color: AppColors.dividerColor,
              ),
              itemBuilder: (context, index) {
                final visitor = visitors[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMD,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(visitor['avatar']!),
                  ),
                  title: Text(
                    visitor['name']!,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    visitor['time']!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'Suivre',
                      style: TextStyle(color: AppColors.primaryOrange, fontSize: 13),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
