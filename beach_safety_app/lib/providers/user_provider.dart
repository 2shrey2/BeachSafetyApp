import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../services/mock_data_service.dart';
import '../constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
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
      if (!AppConstants.useRealBackend) {
        // Use mock data for development
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        _user = MockDataService.getMockUser();
      } else {
        _user = await _userService.getUserProfile();
      }
    } catch (e) {
      _error = e.toString();
      
      // Try to get the user from the auth service if the profile API fails
      try {
        final isLoggedIn = await _authService.isLoggedIn();
        if (isLoggedIn && _user == null) {
          // If we're logged in but don't have user data, use mock data
          _user = MockDataService.getMockUser();
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
      if (!AppConstants.useRealBackend) {
        // Use mock data for development
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        
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
        
        // Update the user
        _user = updatedUser;
        
        // Cache the updated user data
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_profile', updatedUser.toJson().toString());
        } catch (e) {
          print('Failed to cache user data: $e');
        }
      } else {
        // Use real backend
        final updatedUser = await _userService.updateUserProfile(
          name: name,
          email: email,
          location: location,
          notificationPreferences: notificationPreferences,
        );
        
        _user = updatedUser;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
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
      if (!AppConstants.useRealBackend) {
        // Use mock data for development
        await Future.delayed(const Duration(seconds: 1));
        _notifications = MockDataService.getMockNotifications();
      } else {
        _notifications = await _userService.getUserNotifications();
      }
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
    
    if (!AppConstants.useRealBackend) {
      // Just simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    
    try {
      await _userService.markNotificationAsRead(notificationId);
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
      if (!AppConstants.useRealBackend) {
        // Just simulate API call
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }
      
      await _userService.updateUserLocation(latitude, longitude);
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