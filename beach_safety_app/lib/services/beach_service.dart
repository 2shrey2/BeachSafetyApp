import '../constants/app_constants.dart';
import '../models/beach_model.dart';
import 'api_service.dart';

class BeachService {
  final ApiService _apiService = ApiService();

  // Get all beaches
  Future<List<Beach>> getBeaches({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? searchQuery,
    String? sortBy,
    String? category,
  }) async {
    try {
      if (AppConstants.logApiCalls) {
        print('Getting beaches with page=$page, pageSize=$pageSize, sortBy=$sortBy');
      }
      
      final response = await _apiService.get(
        ApiEndpoints.beaches,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (searchQuery != null) 'search': searchQuery,
          if (sortBy != null) 'sort_by': sortBy,
          if (category != null) 'category': category,
        },
      );
      
      // The API response might be directly a list instead of having a data property
      if (response is List) {
        return response.map((json) => _mapApiBeachToModel(json)).toList();
      } else if (response is Map && response.containsKey('data')) {
        List<dynamic> beachesJson = response['data'];
        return beachesJson.map((json) => _mapApiBeachToModel(json)).toList();
      } else {
        // Handle case where response is directly the JSON data we need
        return [response].map((json) => _mapApiBeachToModel(json)).toList();
      }
    } catch (e) {
      print('Error in getBeaches: $e');
      rethrow;
    }
  }

  // Get beach details by ID
  Future<Beach> getBeachDetails(String beachId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.beachDetails(beachId),
      );
      
      if (response is Map && response.containsKey('data')) {
        return _mapApiBeachToModel(response['data']);
      } else {
        // Handle case where response is directly the JSON data we need
        return _mapApiBeachToModel(response);
      }
    } catch (e) {
      print('Error in getBeachDetails: $e');
      rethrow;
    }
  }

  // Get beach conditions
  Future<BeachConditions> getBeachConditions(String beachId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.beachConditions(beachId),
      );
      
      if (response is Map && response.containsKey('data')) {
        return _mapApiConditionsToModel(response['data']);
      } else {
        // Handle case where response is directly the JSON data we need
        return _mapApiConditionsToModel(response);
      }
    } catch (e) {
      print('Error in getBeachConditions: $e');
      rethrow;
    }
  }

  // Add beach to favorites
  Future<void> addToFavorites(String beachId) async {
    await _apiService.post(
      ApiEndpoints.favoriteBeach(beachId),
    );
  }

  // Remove beach from favorites
  Future<void> removeFromFavorites(String beachId) async {
    await _apiService.delete(
      ApiEndpoints.favoriteBeach(beachId),
    );
  }

  // Get nearby beaches
  Future<List<Beach>> getNearbyBeaches(
    double latitude,
    double longitude, {
    double radius = 50.0,
  }) async {
    try {
      print('Sending GET request to ${ApiEndpoints.beachesNearby} with query params: {lat: $latitude, lng: $longitude, radius: $radius}');
      
      final response = await _apiService.get(
        ApiEndpoints.beachesNearby,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radius,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> beachesJson = response.data['beaches'] ?? response.data;
        return beachesJson.map((json) => _mapApiBeachToModel(json)).toList();
      } else {
        throw Exception('Failed to get nearby beaches: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getNearbyBeaches: $e');
      rethrow;
    }
  }

  // Get favorite beaches for the current user
  Future<List<Beach>> getFavoriteBeaches() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.favoriteBeaches,
      );
      
      if (response is List) {
        return response.map((json) => _mapApiBeachToModel(json)).toList();
      } else if (response is Map && response.containsKey('data')) {
        List<dynamic> beachesJson = response['data'];
        return beachesJson.map((json) => _mapApiBeachToModel(json)).toList();
      } else {
        // Empty list or unexpected response format
        return [];
      }
    } catch (e) {
      print('Error in getFavoriteBeaches: $e');
      rethrow;
    }
  }
  
  // Map API beach format to our Beach model
  Beach _mapApiBeachToModel(Map<String, dynamic> apiBeach) {
    String? imageUrl = apiBeach['image_url'];
    
    // Use the image URL optimizer from AppConstants
    imageUrl = AppConstants.getOptimizedImageUrl(imageUrl);
    
    // Debugging image URLs
    print('Original image URL: ${apiBeach['image_url']}');
    print('Optimized image URL: $imageUrl');
    
    return Beach(
      id: apiBeach['id'].toString(),
      name: apiBeach['name'],
      location: apiBeach['location'] ?? "${apiBeach['city']}, ${apiBeach['state']}",
      latitude: apiBeach['latitude'],
      longitude: apiBeach['longitude'],
      imageUrl: imageUrl,
      description: apiBeach['description'] ?? '',
      isFavorite: apiBeach['is_favorite'] ?? false,
      // These fields might not be available in the backend response
      rating: apiBeach['rating']?.toDouble(),
      viewCount: apiBeach['view_count'],
      // Current conditions will be fetched separately
      currentConditions: null,
    );
  }
  
  // Map API conditions format to our BeachConditions model
  BeachConditions _mapApiConditionsToModel(Map<String, dynamic> apiConditions) {
    // Extract safety status with fallbacks for different backend field names
    String safetyStatus = 'unknown';
    if (apiConditions.containsKey('safety_status')) {
      safetyStatus = apiConditions['safety_status'];
    } else if (apiConditions.containsKey('suitability_level')) {
      safetyStatus = apiConditions['suitability_level'];
    } else if (apiConditions.containsKey('safety_level')) {
      safetyStatus = apiConditions['safety_level'];
    } else if (apiConditions.containsKey('status')) {
      safetyStatus = apiConditions['status'];
    }
    
    // Log the received safety status
    print('Received safety status: $safetyStatus from backend conditions: $apiConditions');
    
    return BeachConditions(
      safetyStatus: safetyStatus, 
      temperature: apiConditions['water_temperature']?.toDouble() ?? 0.0,
      humidity: apiConditions['humidity'] ?? 0,
      windSpeed: apiConditions['wind_speed']?.toDouble() ?? 0.0,
      windDirection: apiConditions['wind_direction'] ?? 'Unknown',
      waveHeight: apiConditions['wave_height']?.toDouble() ?? 0.0,
      waterQuality: apiConditions['water_quality'],
      timestamp: DateTime.parse(apiConditions['timestamp'] ?? DateTime.now().toIso8601String()),
      additionalData: {
        'safety_score': apiConditions['safety_score'],
        'warning_message': apiConditions['warning_message'],
        'raw_data': apiConditions, // Store the raw data for debugging
      },
    );
  }
  
  // Get beach with conditions (combined data)
  Future<Beach> getBeachWithConditions(String beachId) async {
    final beach = await getBeachDetails(beachId);
    try {
      final conditions = await getBeachConditions(beachId);
      return beach.copyWith(currentConditions: conditions);
    } catch (e) {
      // If conditions fail to load, return the beach without conditions
      print('Failed to load conditions for beach $beachId: $e');
      return beach;
    }
  }
} 