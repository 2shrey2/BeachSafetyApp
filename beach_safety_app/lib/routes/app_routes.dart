import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/beach/beach_details_screen.dart';
import '../screens/main_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/profile/favorites_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String main = '/main';
  static const String login = '/login';
  static const String register = '/register';
  static const String beachDetails = '/beach-details';
  static const String notifications = '/notifications';
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

  // Get all routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      main: (context) => const MainScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      notifications: (context) => const NotificationsScreen(),
      favorites: (context) => const FavoritesScreen(),
    };
  }

  // Handle route generation
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case beachDetails:
        final beachId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => BeachDetailsScreen(
            beachId: beachId,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }

  // Route configurations
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    main: (context) => const MainScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    favorites: (context) => const FavoritesScreen(),
    notifications: (context) => const NotificationsScreen(),
  };

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

  // Navigation helpers
  static Future<void> navigateToMain(BuildContext context) {
    return Navigator.of(context).pushReplacementNamed(main);
  }

  static Future<void> navigateToLogin(BuildContext context) {
    return Navigator.of(context).pushReplacementNamed(login);
  }

  static Future<void> navigateToRegister(BuildContext context) {
    return Navigator.of(context).pushReplacementNamed(register);
  }

  static Future<void> navigateToBeachDetails(BuildContext context, String beachId) {
    return Navigator.of(context).pushNamed(
      beachDetails,
      arguments: beachId,
    );
  }

  static Future<void> navigateToFavorites(BuildContext context) {
    return Navigator.of(context).pushNamed(favorites);
  }

  static Future<void> navigateToNotifications(BuildContext context) {
    return Navigator.of(context).pushNamed(notifications);
  }

  static void popToMain(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == main,
    );
  }
} 