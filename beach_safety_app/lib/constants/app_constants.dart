import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // App Metadata
  static const String appName = 'Beach Safety';
  static const String appVersion = '1.0.0';
  
  // API Base URL - Use window.location.hostname when running on web
  static String get baseUrl {
    // Detect development vs production environment
    const bool isDevelopment = true; // Set to false for production
    
    if (isDevelopment) {
      if (kIsWeb) {
        // For web in development, use the current hostname with the correct port
        return 'http://127.0.0.1:8000';  // Removed /api/v1 since it will be added in endpoints
      } else if (Platform.isAndroid) {
        // For Android emulator, use 10.0.2.2 which maps to host's localhost
        return 'http://10.0.2.2:8000';
      } else {
        // For iOS simulator and physical devices
        return 'http://127.0.0.1:8000';
      }
    } else {
      // Production URLs - replace with your actual production backend URL
      return 'https://your-production-backend.com';  // Replace with your actual production URL
    }
  }
  
  // Default Values
  static const int defaultPageSize = 20;
  static const double defaultAnimationDuration = 300; // milliseconds
  
  // Map Constants
  static const double defaultZoomLevel = 12.0;
  static const double defaultLatitude = 18.5204; // Pune as default
  static const double defaultLongitude = 73.8568;
  
  // Safety Status Colors
  static const Map<String, String> safetyStatusColors = {
    'safe': '#4CAF50',
    'moderate': '#FFC107',
    'dangerous': '#F44336',
    'closed': '#9E9E9E',
  };

  // Error Messages
  static const String defaultErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String authErrorMessage = 'Authentication failed. Please log in again.';

  // Backend authentication settings
  static bool _useRealBackend = true; // Make this a private variable
  static bool get useRealBackend => _useRealBackend; // Getter
  static set useRealBackend(bool value) => _useRealBackend = value; // Setter
  
  // Image URLs
  static const String defaultBeachImage = 'assets/images/beach.jpg';
  static const String cloudinaryBaseUrl = 'https://res.cloudinary.com/duouemoop/image/upload/';
  
  static String getOptimizedImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return defaultBeachImage;
    }
    
    // If it's an asset, return as is
    if (imageUrl.startsWith('assets/')) {
      return imageUrl;
    }
    
    // If it's already a Cloudinary URL, optimize it
    if (imageUrl.contains('cloudinary.com')) {
      // Extract the ID part from the URL
      final regex = RegExp(r'upload\/([^\/]+\/[^\/]+)$');
      final match = regex.firstMatch(imageUrl);
      if (match != null) {
        // Add optimization parameters (w_500 = width 500px, q_auto = auto quality)
        return '${cloudinaryBaseUrl}w_500,q_auto/${match.group(1)}';
      }
    }
    
    // Return the URL as is if not matching any known pattern
    return imageUrl;
  }
  
  static const bool logApiCalls = true; // Set to false in production
}

// API Endpoints moved to top level
class ApiEndpoints {
  // API prefix
  static const String apiPrefix = '/api/v1';
  
  // Health check endpoint (no prefix)
  static const String health = '/health';
  
  // Auth Endpoints
  static const String register = '$apiPrefix/auth/register';
  static const String login = '$apiPrefix/auth/login';
  static const String refreshToken = '$apiPrefix/auth/refresh';
  
  // Beach Endpoints
  static const String beaches = '$apiPrefix/beaches';
  static String beachDetails(String beachId) => '$apiPrefix/beaches/$beachId';
  static String beachConditions(String beachId) => '$apiPrefix/beaches/$beachId/conditions';
  static const String beachesNearby = '$apiPrefix/beaches/nearby';
  static String favoriteBeach(String beachId) => '$apiPrefix/beaches/$beachId/favorite';
  static const String favoriteBeaches = '$apiPrefix/users/me/favorites';
  
  // User Endpoints
  static const String userProfile = '$apiPrefix/users/me';
  static const String userNotifications = '$apiPrefix/users/me/notifications';
  
  // Weather Endpoints
  static const String weatherNearby = '$apiPrefix/weather/nearby';
}

// Storage Keys moved to top level
class StorageKeys { 
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String favoriteBeaches = 'favorite_beaches';
} 