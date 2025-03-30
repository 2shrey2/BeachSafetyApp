import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/beach/beach_details_screen.dart';
import '../screens/main_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String beachDetails = '/beach-details';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      main: (context) => const MainScreen(),
      beachDetails: (context) => BeachDetailsScreen(
            beachId: ModalRoute.of(context)!.settings.arguments as String,
          ),
    };
  }
} 