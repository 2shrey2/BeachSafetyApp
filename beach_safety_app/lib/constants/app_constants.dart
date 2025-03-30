class AppConstants {
  // App Metadata
  static const String appName = 'Beach Safety';
  static const String appVersion = '1.0.0';
  
  // API Base URL
  static const String baseUrl = 'https://api.beachsafety.com/api/v1';
  
  // API Endpoints
  static class ApiEndpoints {
    // Auth Endpoints
    static const String register = '/auth/register';
    static const String login = '/auth/login';
    static const String refreshToken = '/auth/refresh';
    
    // Beach Endpoints
    static const String beaches = '/beaches';
    static String beachDetails(String beachId) => '/beaches/$beachId';
    static String beachConditions(String beachId) => '/beaches/$beachId/conditions';
    static String favoriteBeach(String beachId) => '/beaches/$beachId/favorite';
    
    // User Endpoints
    static const String userProfile = '/users/me';
    static const String userNotifications = '/users/me/notifications';
    
    // Weather Endpoints
    static const String weatherNearby = '/weather/nearby';
  }
  
  // Storage Keys
  static class StorageKeys {
    static const String accessToken = 'access_token';
    static const String refreshToken = 'refresh_token';
    static const String userId = 'user_id';
    static const String userProfile = 'user_profile';
    static const String favoriteBeaches = 'favorite_beaches';
  }
  
  // Default Values
  static const int defaultPageSize = 20;
  static const double defaultAnimationDuration = 300; // milliseconds
  
  // Map Constants
  static const double defaultZoomLevel = 12.0;
  static const double defaultLatitude = 34.0522; // Los Angeles as default
  static const double defaultLongitude = -118.2437;
  
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
} 