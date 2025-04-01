import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/app_constants.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    print('Initializing API Service with baseUrl: ${AppConstants.baseUrl}');
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      headers: {
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
      },
    ));
    
    // For web, we need to disable certificate checking
    if (kIsWeb) {
      // No certificate validation needed for web
    } else if (Platform.isAndroid) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    
    _setupInterceptors();
    
    // Test the connection immediately but don't wait
    testConnection().then((isConnected) {
      print('Backend is ${isConnected ? "available" : "unavailable"}');
    });
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to headers if available
          final token = await _secureStorage.read(key: StorageKeys.accessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              // Try to refresh the token
              final refreshToken = await _secureStorage.read(
                key: StorageKeys.refreshToken,
              );
              
              if (refreshToken != null) {
                final response = await _dio.post(
                  ApiEndpoints.refreshToken,
                  data: {'refresh_token': refreshToken},
                );
                
                if (response.statusCode == 200) {
                  final newToken = response.data['token'];
                  await _secureStorage.write(
                    key: StorageKeys.accessToken,
                    value: newToken,
                  );
                  
                  // Retry the original request
                  error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await _dio.fetch(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (e) {
              // If refresh fails, clear tokens and proceed with error
              await _secureStorage.delete(key: StorageKeys.accessToken);
              await _secureStorage.delete(key: StorageKeys.refreshToken);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: true,
      request: true,
      logPrint: (obj) {
        print('API LOG: $obj'); // In production, use a proper logging library
      },
    ));
  }

  // Test connection to the backend
  Future<bool> testConnection() async {
    try {
      print('Testing connection to backend at: ${AppConstants.baseUrl}');
      
      // First try the health endpoint
      try {
        final healthDio = Dio(BaseOptions(
          baseUrl: '${AppConstants.baseUrl}',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ));
        
        final response = await healthDio.get('/health');
        print('Backend connection successful via health endpoint: ${response.data}');
        return true;
      } catch (healthError) {
        print('Health endpoint failed: $healthError');
        
        // Then try the API v1 root endpoint (using main Dio instance)
        try {
          print('Trying API v1 root endpoint...');
          final response = await _dio.get(ApiEndpoints.apiPrefix);
          print('API V1 endpoint successful: ${response.data}');
          return true;
        } catch (apiError) {
          print('API V1 root endpoint failed: $apiError');
          
          // Finally try the docs endpoint which should be available in FastAPI
          try {
            print('Trying /docs endpoint...');
            final docsDio = Dio(BaseOptions(
              baseUrl: '${AppConstants.baseUrl}',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));
            
            final docsResponse = await docsDio.get('/docs');
            print('Backend connection successful via docs endpoint: ${docsResponse.statusCode}');
            return true;
          } catch (docsError) {
            print('Docs endpoint also failed: $docsError');
            return false;
          }
        }
      }
    } catch (e) {
      print('Backend connection test failed with error: $e');
      return false;
    }
  }

  // Generic GET request
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  // Generic POST request
  Future<dynamic> post(String path, {Object? data}) async {
    try {
      print("Sending POST request to $path with data: $data");
      final response = await _dio.post(path, data: data);
      print("Received response: ${response.data}");
      return response.data;
    } catch (e) {
      print("POST request failed: $e");
      rethrow; // Let the caller handle the error
    }
  }

  // Generic PUT request
  Future<dynamic> put(String path, {Object? data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } catch (e) {
      _handleError(e);
    }
  }

  // Error handler
  void _handleError(dynamic error) {
    print('API Error: $error');
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('${AppConstants.networkErrorMessage} - Timeout error');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final errorData = error.response?.data;
          
          String errorMessage = AppConstants.defaultErrorMessage;
          
          if (errorData != null && errorData is Map<String, dynamic>) {
            errorMessage = errorData['detail'] ?? errorData['message'] ?? AppConstants.defaultErrorMessage;
          }
          
          if (statusCode == 401) {
            throw Exception(AppConstants.authErrorMessage);
          } else {
            throw Exception('Error $statusCode: $errorMessage');
          }
        case DioExceptionType.cancel:
          throw Exception('Request was cancelled');
        case DioExceptionType.connectionError:
          throw Exception('${AppConstants.networkErrorMessage} - Cannot connect to the server. Please check if the backend is running.');
        default:
          throw Exception('${AppConstants.defaultErrorMessage} (${error.type})');
      }
    } else {
      throw Exception('${AppConstants.defaultErrorMessage} - ${error.toString()}');
    }
  }
} 