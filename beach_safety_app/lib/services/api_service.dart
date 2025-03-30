import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));

    _setupInterceptors();
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
                  final newToken = response.data['access_token'];
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
              // If refresh fails, proceed with error
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
      logPrint: (obj) {
        print(obj); // In production, use a proper logging library
      },
    ));
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
      final response = await _dio.post(path, data: data);
      return response.data;
    } catch (e) {
      _handleError(e);
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
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception(AppConstants.networkErrorMessage);
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final errorMessage = error.response?.data?['message'] ?? AppConstants.defaultErrorMessage;
          
          if (statusCode == 401) {
            throw Exception(AppConstants.authErrorMessage);
          } else {
            throw Exception(errorMessage);
          }
        case DioExceptionType.cancel:
          throw Exception('Request was cancelled');
        default:
          throw Exception(AppConstants.defaultErrorMessage);
      }
    } else {
      throw Exception(AppConstants.defaultErrorMessage);
    }
  }
} 