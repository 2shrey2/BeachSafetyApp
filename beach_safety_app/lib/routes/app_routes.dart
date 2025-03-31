import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/beach/beach_details_screen.dart';
import '../screens/main_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/profile/favorites_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String beachDetails = '/beach-details';
  static const String favorites = '/favorites';

  // Route guards
  static bool _handleAuthGuard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed(login);
      return false;
    }
    return true;
  }

  // Route configurations
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      main: (context) => const MainScreen(),
      favorites: (context) => const FavoritesScreen(),
    };
  }

  // Custom page route builder
  static PageRoute _buildPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute(
      builder: builder,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      maintainState: true,
    );
  }

  // Handle route transitions
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Parse route URI for deep linking support
    final uri = Uri.parse(settings.name ?? '');
    final pathSegments = uri.pathSegments;

    // Handle routes that require parameters
    switch (settings.name) {
      case beachDetails:
        // Handle beach details route
        String? beachId;
        if (settings.arguments != null) {
          beachId = settings.arguments as String;
        } else if (pathSegments.length > 1) {
          beachId = pathSegments[1];
        }

        if (beachId == null) {
          return _buildPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text(
                  'Beach ID is required',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            settings: settings,
          );
        }

        return _buildPageRoute(
          builder: (context) => BeachDetailsScreen(beachId: beachId!),
          settings: settings,
        );

      case main:
        // Main screen with auth guard
        return _buildPageRoute(
          builder: (context) {
            if (!_handleAuthGuard(context)) {
              return const LoginScreen();
            }
            return const MainScreen();
          },
          settings: settings,
        );

      case login:
        // Login screen with clear navigation stack
        return _buildPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
          fullscreenDialog: true,
        );

      case register:
        // Register screen with modal presentation
        return _buildPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
          fullscreenDialog: true,
        );

      case favorites:
        // Favorites screen with auth guard
        return _buildPageRoute(
          builder: (context) {
            if (!_handleAuthGuard(context)) {
              return const LoginScreen();
            }
            return const FavoritesScreen();
          },
          settings: settings,
        );

      default:
        // Handle deep links and dynamic routes
        if (pathSegments.isNotEmpty) {
          if (pathSegments[0] == 'beach-details' && pathSegments.length > 1) {
            return _buildPageRoute(
              builder: (_) => BeachDetailsScreen(beachId: pathSegments[1]),
              settings: settings,
            );
          }
        }

        // Default to main screen if route not found
        return _buildPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );
    }
  }

  // Navigation helpers
  static Future<T?> navigateToBeachDetails<T>(
    BuildContext context,
    String beachId, {
    bool replace = false,
  }) {
    if (replace) {
      return Navigator.of(context).pushReplacementNamed(
        beachDetails,
        arguments: beachId,
      );
    }
    return Navigator.of(context).pushNamed(
      beachDetails,
      arguments: beachId,
    );
  }

  static Future<void> navigateToMain(BuildContext context) {
    return Navigator.of(context).pushReplacementNamed(main);
  }

  static Future<void> navigateToLogin(BuildContext context) {
    return Navigator.of(context).pushReplacementNamed(login);
  }

  static Future<void> navigateToRegister(BuildContext context) {
    return Navigator.of(context).pushNamed(register);
  }

  static Future<void> navigateToFavorites(BuildContext context) {
    return Navigator.of(context).pushNamed(favorites);
  }

  static void popToMain(BuildContext context) {
    Navigator.of(context).popUntil(ModalRoute.withName(main));
  }
} 