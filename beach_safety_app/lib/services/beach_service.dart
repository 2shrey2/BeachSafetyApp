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

    List<dynamic> beachesJson = response['data'];
    return beachesJson.map((json) => Beach.fromJson(json)).toList();
  }

  // Get beach details by ID
  Future<Beach> getBeachDetails(String beachId) async {
    final response = await _apiService.get(
      ApiEndpoints.beachDetails(beachId),
    );
    return Beach.fromJson(response['data']);
  }

  // Get beach conditions
  Future<BeachConditions> getBeachConditions(String beachId) async {
    final response = await _apiService.get(
      ApiEndpoints.beachConditions(beachId),
    );
    return BeachConditions.fromJson(response['data']);
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

  // Get nearby beaches based on latitude and longitude
  Future<List<Beach>> getNearbyBeaches(
    double latitude,
    double longitude, {
    double radius = 50.0, // in kilometers
  }) async {
    final response = await _apiService.get(
      '${ApiEndpoints.beaches}/nearby',
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
        'radius': radius,
      },
    );

    List<dynamic> beachesJson = response['data'];
    return beachesJson.map((json) => Beach.fromJson(json)).toList();
  }
} 