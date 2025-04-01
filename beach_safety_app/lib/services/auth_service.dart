import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
    headers: {
      'Accept': 'application/json',
    },
  ));

  // Register a new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // If we're configured to not use the real backend, use mock data right away
    if (!AppConstants.useRealBackend) {
      print('Using mock registration (useRealBackend=false)');
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Create a mock user and token
      final mockUser = User(
        id: '1',
        email: email,
        name: name,
        profileImageUrl: 'assets/images/avatar.jpeg',
        location: '',
        notificationPreferences: {
          'weatherUpdates': true,
          'safetyAlerts': true,
          'beachEvents': false,
        },
      );
      
      // Save mock tokens
      await _secureStorage.write(key: StorageKeys.accessToken, value: 'mock-token');
      await _secureStorage.write(key: StorageKeys.userId, value: '1');
      
      return mockUser;
    }
    
    try {
      if (AppConstants.logApiCalls) {
        print('Attempting to register with backend: $email at ${AppConstants.baseUrl + ApiEndpoints.register}');
      }
      
      // Try to register with the actual API
      final registerData = {
        'full_name': name,
        'email': email,
        'password': password,
      };
      
      print('Sending registration data: $registerData to ${ApiEndpoints.register}');
      
      final response = await _dio.post(
        ApiEndpoints.register,
        data: registerData,
      );

      print('Register response: ${response.data}');
      final responseData = response.data;

      // After registering, log in to get the token
      return login(email: email, password: password);
    } catch (e) {
      print('API Register error: $e');
      
      // If the API is not available, use mock registration for development
      print('Using mock registration after backend error');
      // Create a mock user and token
      final mockUser = User(
        id: '1',
        email: email,
        name: name,
        profileImageUrl: 'assets/images/avatar.jpeg',
      );
      
      // Save mock tokens
      await _secureStorage.write(key: StorageKeys.accessToken, value: 'mock-token');
      await _secureStorage.write(key: StorageKeys.userId, value: '1');
      
      return mockUser;
    }
  }

  // Login user
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // If we're configured to not use the real backend, use mock data right away
    if (!AppConstants.useRealBackend) {
      print('Using mock login (useRealBackend=false)');
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Create a mock user and token
      final mockUser = User(
        id: '1',
        email: email,
        name: 'Kabir',
        profileImageUrl: 'assets/images/avatar.jpeg',
        location: 'Pune, India',
        notificationPreferences: {
          'weatherUpdates': true,
          'safetyAlerts': true,
          'beachEvents': false,
        },
      );
      
      // Save mock tokens
      await _secureStorage.write(key: StorageKeys.accessToken, value: 'mock-token');
      await _secureStorage.write(key: StorageKeys.userId, value: '1');
      
      return mockUser;
    }
    
    try {
      if (AppConstants.logApiCalls) {
        print('Attempting to login with backend: $email at ${AppConstants.baseUrl + ApiEndpoints.login}');
      }
      
      // For FastAPI OAuth2 password flow
      final data = {
        'username': email,
        'password': password,
      };
      
      // Convert data to form URL encoded format
      final formData = data.entries.map((e) => 
        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
      
      print('Sending login data to ${ApiEndpoints.login} with data: $data');
      
      final response = await _dio.post(
        ApiEndpoints.login,
        data: formData,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        if (responseData['access_token'] != null) {
          // Save the tokens
          final accessToken = responseData['access_token'];
          final tokenType = responseData['token_type'] ?? 'bearer';
          
          // Save authentication data
          await _secureStorage.write(key: StorageKeys.accessToken, value: accessToken);
          
          // Get user profile with the new token
          _dio.options.headers['Authorization'] = '$tokenType $accessToken';
          
          try {
            final userResponse = await _dio.get(ApiEndpoints.userProfile);
            print('User profile retrieved: ${userResponse.data}');
            
            final userData = userResponse.data;
            
            final userId = userData['id']?.toString() ?? '1';
            await _secureStorage.write(key: StorageKeys.userId, value: userId);
            
            return User.fromJson(userData);
          } catch (profileError) {
            print('Error fetching user profile: $profileError');
            // If we couldn't get the profile, create a minimal user
            return User(
              id: '1',
              email: email,
              name: email.split('@')[0],
            );
          }
        } else {
          throw Exception('Login failed: No access token in response');
        }
      } else {
        final errorMessage = response.data['detail'] ?? 'Login failed';
        throw Exception('Login failed: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('API Login error: $e');
      
      // If the API is not available, use mock login for development
      if (email == 'test@example.com' && password == 'password') {
        print('Using mock login after backend error');
        
        // Create a mock user and token
        final mockUser = User(
          id: '1',
          email: email,
          name: 'Kabir',
          profileImageUrl: 'assets/images/avatar.jpeg',
          location: 'Pune, India',
          notificationPreferences: {
            'weatherUpdates': true,
            'safetyAlerts': true,
            'beachEvents': false,
          },
        );
        
        // Save mock tokens
        await _secureStorage.write(key: StorageKeys.accessToken, value: 'mock-token');
        await _secureStorage.write(key: StorageKeys.userId, value: '1');
        
        return mockUser;
      }
      
      // Rethrow the original error if mock login doesn't match
      throw Exception(e.toString());
    }
  }

  // Save authentication tokens
  Future<void> _saveTokens(Map<String, dynamic> response) async {
    await _secureStorage.write(
      key: StorageKeys.accessToken,
      value: response['token'],
    );
    
    if (response['refresh_token'] != null) {
      await _secureStorage.write(
        key: StorageKeys.refreshToken,
        value: response['refresh_token'],
      );
    }
    
    await _secureStorage.write(
      key: StorageKeys.userId,
      value: response['user']['id'].toString(),
    );
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(
        key: StorageKeys.accessToken,
      );
      return token != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userId);
    await _secureStorage.delete(key: StorageKeys.userProfile);
  }
} 