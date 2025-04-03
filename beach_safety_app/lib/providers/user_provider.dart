import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import 'package:dio/dio.dart';

class UserProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();
  
  User? _user;
  List<UserNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  List<UserNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get user profile information
  Future<void> getUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _dataService.getUserProfile();
    } catch (e) {
      _error = e.toString();
      
      // Try to get the user from the auth service if the profile API fails
      try {
        final isLoggedIn = await _authService.isLoggedIn();
        if (isLoggedIn && _user == null) {
          // If we're logged in but don't have user data, create a minimal user
          print('Creating default user after auth check');
          final userId = await _authService.getUserId();
          if (userId != null) {
            _user = User(
              id: userId,
              name: 'User',
              email: 'user@example.com',
              profileImageUrl: 'assets/images/avatar.jpeg',
            );
          }
        }
      } catch (authErr) {
        print('Failed to get auth user: $authErr');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Set user data from login/register
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? location,
    Map<String, bool>? notificationPreferences,
  }) async {
    if (_user == null) {
      _error = 'No user data available';
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create updated user object
      final updatedUser = User(
        id: _user!.id,
        name: name ?? _user!.name,
        email: email ?? _user!.email,
        location: location ?? _user!.location,
        profileImageUrl: _user!.profileImageUrl,
        favoriteBeachIds: _user!.favoriteBeachIds,
        notificationPreferences: notificationPreferences ?? _user!.notificationPreferences,
      );
      
      // Update via DataService
      final success = await _dataService.updateUserProfile(updatedUser);
      
      if (success) {
        _user = updatedUser;
      } else {
        _error = 'Failed to update profile';
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get user notifications
  Future<void> getUserNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _dataService.getUserNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index == -1) return;
    
    // Update locally first for immediate UI feedback
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
    
    try {
      final success = await _dataService.markNotificationAsRead(notificationId);
      if (!success) {
        // If not successful, revert
        _notifications[index] = _notifications[index].copyWith(isRead: false);
        _error = 'Failed to mark notification as read';
        notifyListeners();
      }
    } catch (e) {
      // If error, revert
      _notifications[index] = _notifications[index].copyWith(isRead: false);
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Update user location
  Future<void> updateUserLocation(double latitude, double longitude) async {
    try {
      await _dataService.updateUserLocation(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Test API connection
  Future<bool> testConnection() async {
    try {
      print('Testing API connection to: ${AppConstants.baseUrl}');
      final dio = Dio(BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      
      // Try to access the health endpoint
      try {
        final response = await dio.get('/health');
        print('Health endpoint response: ${response.statusCode}');
        return true;
      } catch (healthError) {
        print('Health endpoint error: $healthError');
        
        // Try the docs endpoint
        try {
          final response = await dio.get('/docs');
          print('Docs endpoint response: ${response.statusCode}');
          return true;
        } catch (docsError) {
          print('Docs endpoint error: $docsError');
          return false;
        }
      }
    } catch (e) {
      print('API connection test failed: $e');
      return false;
    }
  }
} 