import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:beach_safety_app/constants/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  Map<String, dynamic>? _selectedBeach;

  // Initial camera position (centered on India)
  static const LatLng _defaultLocation = LatLng(20.5937, 78.9629);

  // Sample beach data with real Indian beaches
  final List<Map<String, dynamic>> _beaches = [
    {
      'name': 'Juhu Beach',
      'location': const LatLng(19.0969, 72.8278),
      'safety': 'moderate',
      'description': 'Popular beach in Mumbai with moderate safety conditions',
      'weather': 'Partly Cloudy',
      'temperature': '28°C',
      'waveHeight': '1.2m',
      'details':
          'One of the most popular beaches in Mumbai, known for its street food and water sports. Best visited during early morning or evening.',
    },
    {
      'name': 'Marina Beach',
      'location': const LatLng(13.0569, 80.2425),
      'safety': 'safe',
      'description': 'Longest urban beach in India with good safety conditions',
      'weather': 'Sunny',
      'temperature': '32°C',
      'waveHeight': '0.8m',
      'details':
          'The second longest urban beach in the world, stretching over 13 km. Famous for its sunrise and sunset views.',
    },
    {
      'name': 'Varkala Beach',
      'location': const LatLng(8.7377, 76.7067),
      'safety': 'danger',
      'description': 'Beach with strong currents, exercise caution',
      'weather': 'Cloudy',
      'temperature': '30°C',
      'waveHeight': '2.5m',
      'details':
          'Known for its natural springs and cliff-side views. Strong currents make swimming challenging.',
    },
    {
      'name': 'Calangute Beach',
      'location': const LatLng(15.5439, 73.7553),
      'safety': 'safe',
      'description': 'Popular beach in Goa with calm waters',
      'weather': 'Sunny',
      'temperature': '29°C',
      'waveHeight': '0.5m',
      'details':
          'The largest beach in North Goa, perfect for swimming and water sports. Popular tourist destination.',
    },
    {
      'name': 'Kovalam Beach',
      'location': const LatLng(8.3988, 76.9780),
      'safety': 'moderate',
      'description': 'Famous beach in Kerala with moderate conditions',
      'weather': 'Partly Cloudy',
      'temperature': '31°C',
      'waveHeight': '1.5m',
      'details':
          'Famous for its Ayurvedic treatments and water sports. Three crescent-shaped beaches.',
    },
    {
      'name': 'Radhanagar Beach',
      'location': const LatLng(11.9689, 92.9356),
      'safety': 'safe',
      'description': 'Beautiful beach in Andaman Islands',
      'weather': 'Sunny',
      'temperature': '27°C',
      'waveHeight': '0.7m',
      'details':
          'Voted as Asia\'s best beach. Crystal clear waters and pristine white sand.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setupBeachMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Handle denied permission
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _updateCameraPosition();
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _updateCameraPosition() {
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          10,
        ),
      );
    }
  }

  void _setupBeachMarkers() {
    setState(() {
      _markers = _beaches.map((beach) {
        return Marker(
          markerId: MarkerId(beach['name']),
          position: beach['location'],
          onTap: () => _showBeachDetails(beach),
          infoWindow: InfoWindow(
            title: beach['name'],
            snippet:
                '${beach['weather']} • ${beach['temperature']} • Waves: ${beach['waveHeight']}',
          ),
          icon: _getMarkerIcon(beach['safety']),
        );
      }).toSet();
      _isLoading = false;
    });
  }

  void _showBeachDetails(Map<String, dynamic> beach) {
    setState(() {
      _selectedBeach = beach;
    });

    // Animate camera to the selected beach
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(beach['location'], 12),
    );

    // Show bottom sheet with beach details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        beach['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _getSafetyColor(beach['safety']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          beach['safety'].toUpperCase(),
                          style: TextStyle(
                            color: _getSafetyColor(beach['safety']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(Icons.wb_sunny, beach['weather']),
                      _buildInfoItem(Icons.thermostat, beach['temperature']),
                      _buildInfoItem(Icons.waves, beach['waveHeight']),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    beach['details'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSafetyColor(String safety) {
    switch (safety) {
      case 'safe':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'danger':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  BitmapDescriptor _getMarkerIcon(String safety) {
    switch (safety) {
      case 'safe':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'moderate':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow);
      case 'danger':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Safety Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _updateCameraPosition,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _defaultLocation,
              zoom: 5,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
            compassEnabled: true,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegendItem('Safe', Colors.green),
                        _buildLegendItem('Moderate', Colors.yellow),
                        _buildLegendItem('Danger', Colors.red),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWeatherInfo('Weather', Icons.wb_sunny),
                        _buildWeatherInfo('Temperature', Icons.thermostat),
                        _buildWeatherInfo('Wave Height', Icons.waves),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildWeatherInfo(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
