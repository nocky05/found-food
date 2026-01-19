import 'package:go_router/go_router.dart';
import 'package:found_food/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:found_food/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:found_food/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:found_food/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:found_food/features/feed/presentation/screens/feed_screen.dart';
import 'package:found_food/features/profile/presentation/screens/profile_screen.dart';
import 'package:found_food/features/search/presentation/screens/search_screen.dart';
import 'package:found_food/features/places/presentation/screens/place_details_screen.dart';
import 'package:found_food/features/places/presentation/screens/add_place_screen.dart';
import 'package:found_food/features/posts/presentation/screens/create_post_screen.dart';
import 'package:found_food/features/posts/presentation/screens/post_details_screen.dart';
import 'package:found_food/features/social/presentation/screens/followers_screen.dart';
import 'package:found_food/features/social/presentation/screens/following_screen.dart';
import 'package:found_food/features/social/presentation/screens/profile_visitors_screen.dart';
import 'package:found_food/features/map/presentation/screens/map_screen.dart';
import 'package:found_food/core/config/supabase_config.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = SupabaseConfig.auth.currentUser != null;
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isAuth = state.matchedLocation.startsWith('/auth');

      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && !isOnboarding && !isAuth) {
        return '/auth/signin';
      }

      // If authenticated and on auth/onboarding screens
      if (isAuthenticated && (isOnboarding || isAuth)) {
        return '/feed';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication
      GoRoute(
        path: '/auth/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main App
      GoRoute(
        path: '/feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Places
      GoRoute(
        path: '/place/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlaceDetailsScreen(placeId: id);
        },
      ),
      GoRoute(
        path: '/add-place',
        builder: (context, state) => const AddPlaceScreen(),
      ),

      // Posts
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostDetailsScreen(postId: id);
        },
      ),

      // Social
      GoRoute(
        path: '/followers/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return FollowersScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/following/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return FollowingScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile-visitors',
        builder: (context, state) => const ProfileVisitorsScreen(),
      ),

      // Map
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
    ],
  );
}
