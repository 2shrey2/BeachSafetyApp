import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/beach_provider.dart';
import 'providers/user_provider.dart';
import 'routes/app_routes.dart';
import 'constants/app_constants.dart';
import 'screens/splash_screen.dart';

// Detect web platform
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui_web' as ui_web;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Add error handling for Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter error: ${details.exception}');
  };

  // Set web-specific settings for images
  if (kIsWeb) {
    // Disable CORS checks for local development
    // Note: In production, you should use proper CORS headers on your server
    // or use a CORS proxy

    // Set platform override to prevent certain platform-specific issues
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    // Force single threaded initialization which can help with initial rendering issues
    PlatformDispatcher.instance.onError = (error, stack) {
      print('PlatformDispatcher error: $error');
      return true;
    };
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Log the status of "useRealBackend"
    print('Using real backend: ${AppConstants.useRealBackend}');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => BeachProvider()),
        ChangeNotifierProvider(create: (ctx) => UserProvider()),
      ],
      child: Builder(builder: (context) {
        // Initialize providers if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<AuthProvider>(context, listen: false).setContext(context);

          // Test API connection
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.testConnection().then((connected) {
            print('API Connection test result: $connected');
          });
        });

        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.getRoutes(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
          navigatorObservers: [RouteObserver<PageRoute>()],
          shortcuts: kIsWeb ? <LogicalKeySet, Intent>{} : null,
          themeMode: ThemeMode.light,
        );
      }),
    );
  }
}