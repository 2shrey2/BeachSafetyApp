import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/beach_model.dart';
import '../services/data_service.dart';
import '../constants/app_constants.dart';

class BeachProvider with ChangeNotifier {
  final DataService _dataService = DataService();

  List<Beach> _beaches = [];
  List<Beach> _favoriteBeaches = [];
  Beach? _selectedBeach;
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _searchQuery;
  String? _sortBy;
  String? _category;

  List<Beach> get beaches => _beaches;
  List<Beach> get favoriteBeaches => _favoriteBeaches;
  Beach? get selectedBeach => _selectedBeach;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Get beaches with optional filtering
  Future<void> getBeaches({
    bool refresh = false,
    String? searchQuery,
    String? sortBy,
    String? category,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _beaches = [];
      _hasMore = true;
      _searchQuery = searchQuery;
      _sortBy = sortBy;
      _category = category;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newBeaches = await _dataService.getBeaches(
        page: _currentPage,
        searchQuery: _searchQuery,
        sortBy: _sortBy,
        category: _category,
      );

      if (newBeaches.isEmpty) {
        _hasMore = false;
      } else {
        _beaches.addAll(newBeaches);
        _currentPage++;
        
        // If we're running on web, replace remote image URLs with local assets
        if (kIsWeb) {
          _beaches = _beaches.map((beach) {
            // Use local asset instead of remote URL to avoid CORS issues
            if (beach.imageUrl != null && !beach.imageUrl!.startsWith('assets/')) {
              return beach.copyWith(
                imageUrl: 'assets/images/beach.jpeg',
              );
            }
            return beach;
          }).toList();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get beach details by ID
  Future<void> getBeachDetails(String beachId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedBeach = await _dataService.getBeachDetails(beachId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle favorite status for a beach
  Future<void> toggleFavorite(String beachId) async {
    // Find beach in the list
    final index = _beaches.indexWhere((beach) => beach.id == beachId);
    if (index == -1 && _selectedBeach?.id != beachId) return;

    // Toggle favorite status locally for immediate UI update
    Beach? beach;
    bool newFavoriteStatus = false;
    
    if (index != -1) {
      beach = _beaches[index];
      newFavoriteStatus = !beach.isFavorite;
      
      // Update local state
      _beaches[index] = beach.copyWith(isFavorite: newFavoriteStatus);
    }
    
    // If selected beach is being toggled, update that too
    if (_selectedBeach?.id == beachId) {
      newFavoriteStatus = !_selectedBeach!.isFavorite;
      _selectedBeach = _selectedBeach!.copyWith(isFavorite: newFavoriteStatus);
    }
    
    // Update favorites list
    if (newFavoriteStatus) {
      // If we're adding a favorite, add it to the favorites list
      final beachToAdd = beach ?? _selectedBeach!;
      if (!_favoriteBeaches.any((b) => b.id == beachId)) {
        _favoriteBeaches.add(beachToAdd);
      }
    } else {
      // If we're removing a favorite, remove it from the favorites list
      _favoriteBeaches.removeWhere((b) => b.id == beachId);
    }
    
    notifyListeners();

    // Update on the backend
    try {
      await _dataService.toggleFavorite(beachId, newFavoriteStatus);
      
      // Refresh favorites list if needed
      if (newFavoriteStatus) {
        // Optionally reload to get the latest data
        // await getFavoriteBeaches();
      }
    } catch (e) {
      // If there's an error, revert the change
      if (index != -1) {
        _beaches[index] = beach!.copyWith(isFavorite: !newFavoriteStatus);
      }
      
      if (_selectedBeach?.id == beachId) {
        _selectedBeach = _selectedBeach!.copyWith(isFavorite: !newFavoriteStatus);
      }
      
      // Also update the favorites list
      if (!newFavoriteStatus) {
        // We removed it, but there was an error, so add it back
        if (beach != null && !_favoriteBeaches.any((b) => b.id == beachId)) {
          _favoriteBeaches.add(beach);
        } else if (_selectedBeach != null && _selectedBeach!.id == beachId && 
            !_favoriteBeaches.any((b) => b.id == beachId)) {
          _favoriteBeaches.add(_selectedBeach!);
        }
      } else {
        // We added it, but there was an error, so remove it
        _favoriteBeaches.removeWhere((b) => b.id == beachId);
      }
      
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get nearby beaches with optional parameters
  Future<void> getNearbyBeaches({
    double? latitude,
    double? longitude,
    bool refresh = false,
  }) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    if (refresh) {
      _error = null;
    }
    notifyListeners();

    try {
      // Use provided coordinates or default to Pune
      final double lat = latitude ?? AppConstants.defaultLatitude;
      final double lng = longitude ?? AppConstants.defaultLongitude;
      
      final nearbyBeaches = await _dataService.getNearbyBeaches(
        lat,
        lng,
        radius: 20.0, // 20km radius
      );
      
      // Update the beaches list while preserving favorite status
      final List<Beach> updatedBeaches = nearbyBeaches.map((newBeach) {
        // Check if this beach exists in current list and preserve its favorite status
        final existingBeach = _beaches.firstWhere(
          (beach) => beach.id == newBeach.id,
          orElse: () => newBeach,
        );
        return newBeach.copyWith(isFavorite: existingBeach.isFavorite);
      }).toList();

      _beaches = updatedBeaches;
      
      // Update favorite status from favorites list
      for (final favoriteBeach in _favoriteBeaches) {
        final index = _beaches.indexWhere((b) => b.id == favoriteBeach.id);
        if (index != -1) {
          _beaches[index] = _beaches[index].copyWith(isFavorite: true);
        }
      }
    } catch (e) {
      debugPrint('Error fetching nearby beaches: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get nearby beaches with specific coordinates (returns list without updating state)
  Future<List<Beach>> getNearbyBeachesWithCoordinates(double latitude, double longitude) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final beaches = await _dataService.getNearbyBeaches(latitude, longitude, radius: 20);
      _isLoading = false;
      notifyListeners();
      return beaches;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Get favorite beaches for the current user
  Future<void> getFavoriteBeaches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Getting favorite beaches from DataService');
      final favorites = await _dataService.getFavoriteBeaches();
      
      // Store favorites in a separate list for easy access
      _favoriteBeaches = favorites;
      
      // Debug log
      print('Got ${_favoriteBeaches.length} favorite beaches');
      for (final beach in _favoriteBeaches) {
        print('Favorite beach: ${beach.name}, image: ${beach.imageUrl}, isFavorite: ${beach.isFavorite}');
      }
      
      // Also update isFavorite status in _beaches list if the same beaches exist there
      for (final favoriteBeach in _favoriteBeaches) {
        final index = _beaches.indexWhere((b) => b.id == favoriteBeach.id);
        if (index != -1) {
          _beaches[index] = _beaches[index].copyWith(isFavorite: true);
        }
      }
    } catch (e) {
      print('Error getting favorite beaches: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Update user location
  Future<void> updateUserLocation(double latitude, double longitude) async {
    try {
      await _dataService.updateUserLocation(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('Error updating user location: $e');
      _error = e.toString();
      notifyListeners();
    }
  }
} 