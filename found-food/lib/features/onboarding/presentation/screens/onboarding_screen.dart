import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/shared/widgets/buttons/custom_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      imageUrl: 'assets/images/onboarding/page1.png',
      title: 'Partagez vos meilleures adresses',
      description: 'Ajoutez facilement photos, menus et avis pour guider la communauté',
    ),
    OnboardingPage(
      imageUrl: 'assets/images/onboarding/page2.png',
      title: 'Votre profil gourmand vous attend',
      description: 'Créez-le pour partager, explorer et connecter avec une communauté de passionnés.',
    ),
    OnboardingPage(
      imageUrl: 'assets/images/onboarding/page3.png',
      title: 'Découvrez les meilleurs lieux',
      description: 'Trouvez des restaurants, parcs et espaces selon votre budget et proximité',
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Bottom section with indicators, button, and skip
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Skip button
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Passer',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Column(
      children: [
        // Image (takes 60% of screen)
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Image.asset(
                page.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.lightPeach,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Content (takes 40% of screen)
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  page.title,
                  style: AppTypography.h2.copyWith(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  page.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Button
                PrimaryButton(
                  text: _currentPage == _pages.length - 1 ? 'Commencer' : 'Suivant',
                  onPressed: _nextPage,
                  backgroundColor: AppColors.primaryOrange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryOrange : const Color(0xFFDFE6E9),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String imageUrl;
  final String title;
  final String description;

  OnboardingPage({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}
