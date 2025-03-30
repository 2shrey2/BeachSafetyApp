import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../services/user_service.dart';
import '../services/mock_data_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  
  User? _user;
  List<UserNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  
  // For demo, set to true to use mock data
  final bool _useMockData = true;

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
      if (_useMockData) {
        // Use mock data for development
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        _user = MockDataService.getMockUser();
      } else {
        _user = await _userService.getUserProfile();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? location,
    Map<String, bool>? notificationPreferences,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useMockData) {
        // Use mock data for development
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        
        // Update local mock user
        if (_user != null) {
          _user = User(
            id: _user!.id,
            name: name ?? _user!.name,
            email: email ?? _user!.email,
            location: location ?? _user!.location,
            profileImageUrl: _user!.profileImageUrl,
            favoriteBeachIds: _user!.favoriteBeachIds,
            notificationPreferences: notificationPreferences ?? _user!.notificationPreferences,
          );
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _user = await _userService.updateUserProfile(
          name: name,
          email: email,
          location: location,
          notificationPreferences: notificationPreferences,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
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
      if (_useMockData) {
        // Use mock data for development
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
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
    
    if (_useMockData) {
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
      if (_useMockData) {
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
} 