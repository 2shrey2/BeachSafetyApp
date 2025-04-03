import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/beach_model.dart';
import '../../providers/beach_provider.dart';
import '../../routes/app_routes.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  final List<Marker> _markers = [];
  Position? _currentPosition;
  bool _isLoading = true;
  bool _isPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _isPermissionDenied = true;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _isPermissionDenied = true;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _isPermissionDenied = true;
        });
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _loadNearbyBeaches();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error getting location: $e');
    }
  }

  Future<void> _loadNearbyBeaches() async {
    if (_currentPosition == null) return;

    await Provider.of<BeachProvider>(context, listen: false).getNearbyBeaches(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
    );

    _updateMarkers();

    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        12.0,
      );
    }
  }

  void _updateMarkers() {
    final beaches = Provider.of<BeachProvider>(context, listen: false).beaches;
    List<Marker> markers = [];

    // Add user position marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 40,
          height: 40,
          child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
        ),
      );
    }

    // Add beach markers
    for (var beach in beaches) {
      markers.add(
        Marker(
          point: LatLng(beach.latitude, beach.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _navigateToBeachDetails(beach),
            child: Icon(
              Icons.place,
              color: _getMarkerColor(beach.safetyStatus),
              size: 40,
            ),
          ),
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  Color _getMarkerColor(String safetyStatus) {
    switch (safetyStatus.toLowerCase()) {
      case 'safe':
        return Colors.green;
      case 'caution':
        return Colors.yellow;
      case 'dangerous':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToBeachDetails(Beach beach) {
    AppRoutes.navigateToBeachDetails(context, beach.id);
  }

  // Zoom functions
  void _zoomIn() {
    _mapController.move(_mapController.center, _mapController.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.center, _mapController.zoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyBeaches,
          ),
        ],
      ),
      body: Consumer<BeachProvider>(
        builder: (context, beachProvider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_isPermissionDenied) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Location Permission Required',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'We need your location to show beaches near you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            );
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude)
                  : LatLng(20.5937, 78.9629), // Default center: India
              zoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _zoomIn,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _zoomOut,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.remove, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
