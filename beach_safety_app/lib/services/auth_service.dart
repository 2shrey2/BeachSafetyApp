import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Register a new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    await _saveTokens(response);
    return User.fromJson(response['user']);
  }

  // Login user
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    await _saveTokens(response);
    return User.fromJson(response['user']);
  }

  // Save authentication tokens
  Future<void> _saveTokens(Map<String, dynamic> response) async {
    await _secureStorage.write(
      key: StorageKeys.accessToken,
      value: response['access_token'],
    );
    
    await _secureStorage.write(
      key: StorageKeys.refreshToken,
      value: response['refresh_token'],
    );
    
    await _secureStorage.write(
      key: StorageKeys.userId,
      value: response['user']['id'],
    );
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(
      key: StorageKeys.accessToken,
    );
    return token != null;
  }

  // Logout user
  Future<void> logout() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userId);
    await _secureStorage.delete(key: StorageKeys.userProfile);
  }
} 