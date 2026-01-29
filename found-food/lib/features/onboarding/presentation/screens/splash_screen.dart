import 'package:flutter/material.dart';
import 'package:found_food/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate to onboarding after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with dark overlay
          Image.asset(
            'assets/images/splash/background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF121212),
                      Color(0xFF1A1A1A),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Dark Gradient Overlay - Increased opacity to make logo pop
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8), // Darker at top
                  Colors.black.withOpacity(0.6), // Dark in middle
                  Colors.black.withOpacity(0.9), // Almost black at bottom
                ],
              ),
            ),
          ),
          
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Composite Logo Image (contains Logo, Name, and Slogan)
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 300, // Adjusted for full composite logo
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.03), // Reduced opacity for more subtle effect
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant,
                              size: 80,
                              color: Color(0xFFFFD700),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Found-Food',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Optional: Bottom food image reference if asset exists
          // This would be positioned at the very bottom like in the image
        ],
      ),
    );
  }
}
