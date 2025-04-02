import '../models/beach_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../constants/app_constants.dart';
import 'beach_service.dart';
import 'user_service.dart';

/// This class serves as a facade to use real API data
class DataService {
  final BeachService _beachService = BeachService();
  final UserService _userService = UserService();
  
  // Get beaches from API
  Future<List<Beach>> getBeaches({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? searchQuery,
    String? sortBy,
    String? category,
  }) async {
    // Get data from real API
    return await _beachService.getBeaches(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      sortBy: sortBy,
      category: category,
    );
  }
  
  // Get beach details from API
  Future<Beach> getBeachDetails(String beachId) async {
    // Get data from real API with conditions
    return await _beachService.getBeachWithConditions(beachId);
  }
  
  // Get beach conditions from API
  Future<BeachConditions> getBeachConditions(String beachId) async {
    // Get data from real API
    return await _beachService.getBeachConditions(beachId);
  }
  
  // Get nearby beaches from API
  Future<List<Beach>> getNearbyBeaches(
    double latitude,
    double longitude, {
    double radius = 50.0,
  }) async {
    // Get data from real API
    return await _beachService.getNearbyBeaches(
      latitude,
      longitude,
      radius: radius,
    );
  }
  
  // Get favorite beaches from API
  Future<List<Beach>> getFavoriteBeaches() async {
    // Get data from real API
    return await _beachService.getFavoriteBeaches();
  }
  
  // Toggle favorite status for a beach
  Future<void> toggleFavorite(String beachId, bool isFavorite) async {
    if (isFavorite) {
      await _beachService.addToFavorites(beachId);
    } else {
      await _beachService.removeFromFavorites(beachId);
    }
  }
  
  // Get user profile from API
  Future<User?> getUserProfile() async {
    return await _userService.getUserProfile();
  }
  
  // Update user profile
  Future<bool> updateUserProfile(User user) async {
    return await _userService.updateUserProfile(
      name: user.name,
      email: user.email,
      location: user.location,
      notificationPreferences: user.notificationPreferences
    );
  }
  
  // Get user notifications
  Future<List<UserNotification>> getUserNotifications() async {
    return await _userService.getUserNotifications();
  }
  
  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    return await _userService.markNotificationAsRead(notificationId);
  }
  
  // Update user location
  Future<void> updateUserLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _userService.updateUserLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }
} 