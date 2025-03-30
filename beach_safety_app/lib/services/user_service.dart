import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Get user profile
  Future<User> getUserProfile() async {
    final response = await _apiService.get(
      AppConstants.ApiEndpoints.userProfile,
    );
    
    final user = User.fromJson(response['data']);
    
    // Cache user profile
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.StorageKeys.userProfile,
      response['data'].toString(),
    );
    
    return user;
  }

  // Update user profile
  Future<User> updateUserProfile({
    String? name,
    String? email,
    String? location,
    Map<String, bool>? notificationPreferences,
  }) async {
    final response = await _apiService.put(
      AppConstants.ApiEndpoints.userProfile,
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (location != null) 'location': location,
        if (notificationPreferences != null) 'notification_preferences': notificationPreferences,
      },
    );
    
    return User.fromJson(response['data']);
  }

  // Get user notifications
  Future<List<UserNotification>> getUserNotifications() async {
    final response = await _apiService.get(
      AppConstants.ApiEndpoints.userNotifications,
    );
    
    List<dynamic> notificationsJson = response['data'];
    return notificationsJson.map((json) => UserNotification.fromJson(json)).toList();
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _apiService.put(
      '${AppConstants.ApiEndpoints.userNotifications}/$notificationId/read',
    );
  }

  // Update user location
  Future<void> updateUserLocation(double latitude, double longitude) async {
    await _apiService.put(
      AppConstants.ApiEndpoints.userProfile,
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // Get favorite beaches for user
  Future<List<String>> getFavoriteBeachIds() async {
    final user = await getUserProfile();
    return user.favoriteBeachIds;
  }
} 