import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/features/places/presentation/screens/add_place_screen.dart';

class AddSelectionScreen extends StatelessWidget {
  const AddSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background Elements (Decorations)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryOrange.withOpacity(0.1),
              ),
            ),
          ),
           Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryYellow.withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Hero Image or Icon placeholder
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_location_alt_rounded,
                        size: 64,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  Text(
                    'Partagez votre découverte',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ajoutez un lieu, une photo de son menu et racontez votre expérience en une seule étape.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  
                  // Main CTA
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddPlaceScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.secondaryYellow, AppColors.primaryOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Commencer',
                            style: AppTypography.h3.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
