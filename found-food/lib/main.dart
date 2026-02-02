import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/posts/presentation/providers/post_provider.dart';
import 'features/places/presentation/providers/place_provider.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_colors.dart';
import 'features/onboarding/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/presentation/screens/sign_up_email_screen.dart';
import 'features/feed/presentation/screens/feed_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/favorites_screen.dart';
import 'features/map/presentation/screens/map_screen.dart';
import 'features/posts/presentation/screens/add_selection_screen.dart';
import 'shared/widgets/bottom_navigation.dart';

import 'features/profile/presentation/providers/profile_provider.dart';
import 'package:found_food/features/search/data/repositories/search_repository.dart';
import 'package:found_food/features/search/presentation/providers/search_provider.dart';
import 'package:found_food/features/map/presentation/providers/map_provider.dart';
import 'package:found_food/features/stories/presentation/providers/story_provider.dart';
import 'package:found_food/features/social/presentation/providers/follow_provider.dart';
import 'package:found_food/features/social/data/repositories/notification_repository.dart';
import 'package:found_food/features/social/presentation/providers/notification_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/providers/navigation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(
            SearchRepository(Supabase.instance.client),
          ),
        ),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => FollowProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            NotificationRepository(Supabase.instance.client),
          ),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const FoundFoodApp(),
    ),
  );
}

class FoundFoodApp extends StatelessWidget {
  const FoundFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Found-Food',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryOrange,
          secondary: AppColors.secondaryYellow,
        ),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryOrange),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryOrange,
          secondary: AppColors.secondaryYellow,
          surface: Colors.grey[900]!,
        ),
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryOrange),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const MainScreen() : const SplashScreen();
        },
      ),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/signup-email': (context) => const SignUpEmailScreen(),
        '/signin': (context) => const SignInScreen(),
        '/main': (context) => const MainScreen(),
        '/map': (context) => const MapScreen(),
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [
    FeedScreen(),
    SearchScreen(),
    AddSelectionScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, _) {
        return Scaffold(
          body: IndexedStack(
            index: navProvider.currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: navProvider.currentIndex,
            onTap: (index) {
              navProvider.setIndex(index);
            },
          ),
        );
      },
    );
  }
}
