import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/beach_model.dart';
import '../../providers/beach_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _isPermissionDenied = true;
        });
        return;
      }

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

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      await _loadNearbyBeaches();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
    
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          12.0,
        ),
      );
    }
  }

  void _updateMarkers() {
    final beaches = Provider.of<BeachProvider>(context, listen: false).beaches;
    Set<Marker> markers = {};
    
    // Add user position marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }
    
    // Add beach markers
    for (var beach in beaches) {
      markers.add(
        Marker(
          markerId: MarkerId(beach.id),
          position: LatLng(beach.latitude, beach.longitude),
          icon: _getMarkerIcon(beach.safetyStatus),
          infoWindow: InfoWindow(
            title: beach.name,
            snippet: '${beach.safetyStatus} • ${_calculateDistance(beach)}km away',
            onTap: () => _navigateToBeachDetails(beach),
          ),
        ),
      );
    }
    
    setState(() {
      _markers = markers;
    });
  }
  
  BitmapDescriptor _getMarkerIcon(String safetyStatus) {
    switch (safetyStatus.toLowerCase()) {
      case 'safe':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'caution':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case 'dangerous':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }
  
  String _calculateDistance(Beach beach) {
    if (_currentPosition == null) return 'N/A';
    
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      beach.latitude,
      beach.longitude,
    );
    
    return (distanceInMeters / 1000).toStringAsFixed(1);
  }
  
  void _navigateToBeachDetails(Beach beach) {
    Navigator.pushNamed(
      context, 
      '/beach-details',
      arguments: beach.id,
    );
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon')),
              );
            },
          ),
        ],
      ),
      body: Consumer<BeachProvider>(
        builder: (context, beachProvider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (_isPermissionDenied) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Location Permission Required',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            );
          }
          
          if (_currentPosition == null) {
            return const Center(
              child: Text('Unable to get current location'),
            );
          }
          
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  zoom: 12.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                compassEnabled: true,
                mapToolbarEnabled: true,
                zoomControlsEnabled: false,
              ),
              if (beachProvider.isLoading)
                const Positioned(
                  top: 16,
                  right: 16,
                  child: CircularProgressIndicator(),
                ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Beaches Near Me',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Found ${beachProvider.beaches.length} beaches nearby',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildLegendItem('Safe', Colors.green),
                            const SizedBox(width: 16),
                            _buildLegendItem('Caution', Colors.yellow.shade700),
                            const SizedBox(width: 16),
                            _buildLegendItem('Dangerous', Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
} 