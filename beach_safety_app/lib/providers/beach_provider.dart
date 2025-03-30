import 'package:flutter/foundation.dart';
import '../models/beach_model.dart';
import '../services/beach_service.dart';
import '../services/mock_data_service.dart';

class BeachProvider with ChangeNotifier {
  final BeachService _beachService = BeachService();

  List<Beach> _beaches = [];
  Beach? _selectedBeach;
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _searchQuery;
  String? _sortBy;
  String? _category;
  
  // For demo, set to true to use mock data
  final bool _useMockData = true;

  List<Beach> get beaches => _beaches;
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
      if (_useMockData) {
        // Use mock data for development
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        var mockBeaches = MockDataService.getMockBeaches();
        
        // Apply filters if provided
        if (searchQuery != null) {
          mockBeaches = mockBeaches.where((beach) => 
            beach.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            beach.location.toLowerCase().contains(searchQuery.toLowerCase())
          ).toList();
        }
        
        if (sortBy != null) {
          if (sortBy == 'view_count') {
            mockBeaches.sort((a, b) => (b.viewCount ?? 0).compareTo(a.viewCount ?? 0));
          } else if (sortBy == 'created_at') {
            // Mock for "latest" - just randomize for now
            mockBeaches.shuffle();
          }
        }
        
        if (category != null) {
          if (category == 'safe') {
            mockBeaches = mockBeaches.where((beach) => 
              beach.currentConditions?.safetyStatus == 'safe'
            ).toList();
          }
        }
        
        _beaches = mockBeaches;
        _hasMore = false; // Mock data has no pagination
      } else {
        // Use real API
        final newBeaches = await _beachService.getBeaches(
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
      if (_useMockData) {
        // Use mock data for development
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        final mockBeaches = MockDataService.getMockBeaches();
        _selectedBeach = mockBeaches.firstWhere(
          (beach) => beach.id == beachId,
          orElse: () => throw Exception('Beach not found'),
        );
      } else {
        _selectedBeach = await _beachService.getBeachDetails(beachId);
      }
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
    
    notifyListeners();

    if (_useMockData) {
      // Just simulate API call with delay
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    // Update on the server
    try {
      if (newFavoriteStatus) {
        await _beachService.addToFavorites(beachId);
      } else {
        await _beachService.removeFromFavorites(beachId);
      }
    } catch (e) {
      // If there's an error, revert the change
      if (index != -1) {
        _beaches[index] = beach!.copyWith(isFavorite: !newFavoriteStatus);
      }
      
      if (_selectedBeach?.id == beachId) {
        _selectedBeach = _selectedBeach!.copyWith(isFavorite: !newFavoriteStatus);
      }
      
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get nearby beaches with optional parameters
  Future<void> getNearbyBeaches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useMockData) {
        // Use mock data for development
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        var mockBeaches = MockDataService.getMockBeaches();
        
        // Pretend these are sorted by proximity
        mockBeaches.shuffle();
        _beaches = mockBeaches.take(5).toList();
      } else {
        // Default location if actual location not available
        const defaultLatitude = 34.0522; // Los Angeles
        const defaultLongitude = -118.2437;
        
        final nearbyBeaches = await _beachService.getNearbyBeaches(
          defaultLatitude,
          defaultLongitude,
        );
        
        _beaches = nearbyBeaches;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get nearby beaches with specific coordinates
  Future<List<Beach>> getNearbyBeachesWithCoordinates(double latitude, double longitude) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useMockData) {
        // Use mock data for development
        await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
        final mockBeaches = MockDataService.getMockBeaches();
        
        // Pretend these are sorted by proximity
        mockBeaches.shuffle();
        
        _isLoading = false;
        notifyListeners();
        return mockBeaches.take(3).toList();
      } else {
        final nearbyBeaches = await _beachService.getNearbyBeaches(
          latitude,
          longitude,
        );
        
        _isLoading = false;
        notifyListeners();
        return nearbyBeaches;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 