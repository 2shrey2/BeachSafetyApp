import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _currentPosition;
  final MapController _mapController = MapController();
  final List<BeachLocation> _beaches = [
    BeachLocation(
      name: 'Juhu Beach',
      position: LatLng(19.0969, 72.8278),
      safetyRating: 'Safe',
      description:
          'Popular beach in Mumbai with calm waters and good facilities.',
      weatherCondition: 'Sunny',
      temperature: '28°C',
      waveHeight: '0.5m',
    ),
    BeachLocation(
      name: 'Marina Beach',
      position: LatLng(13.0569, 80.2425),
      safetyRating: 'Moderate',
      description: 'Longest urban beach in India, located in Chennai.',
      weatherCondition: 'Partly Cloudy',
      temperature: '30°C',
      waveHeight: '1.2m',
    ),
    BeachLocation(
      name: 'Varkala Beach',
      position: LatLng(8.7377, 76.7067),
      safetyRating: 'Safe',
      description: 'Cliff beach in Kerala with therapeutic waters.',
      weatherCondition: 'Sunny',
      temperature: '29°C',
      waveHeight: '0.8m',
    ),
    BeachLocation(
      name: 'Calangute Beach',
      position: LatLng(15.5439, 73.7553),
      safetyRating: 'Moderate',
      description: 'Popular beach in Goa with water sports activities.',
      weatherCondition: 'Cloudy',
      temperature: '31°C',
      waveHeight: '1.5m',
    ),
    BeachLocation(
      name: 'Kovalam Beach',
      position: LatLng(8.3988, 76.9780),
      safetyRating: 'Safe',
      description: 'Famous beach in Kerala with clear waters.',
      weatherCondition: 'Sunny',
      temperature: '28°C',
      waveHeight: '0.6m',
    ),
    BeachLocation(
      name: 'Radhanagar Beach',
      position: LatLng(11.9689, 92.9555),
      safetyRating: 'Dangerous',
      description: 'Beautiful beach in Havelock Island, Andaman.',
      weatherCondition: 'Rainy',
      temperature: '27°C',
      waveHeight: '2.5m',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          _mapController.zoom,
        );
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _showBeachDetails(BeachLocation beach) {
    _mapController.move(beach.position, 15.0);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getSafetyColor(beach.safetyRating),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    beach.safetyRating,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    beach.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherInfo(
                  Icons.wb_sunny,
                  beach.weatherCondition,
                ),
                _buildWeatherInfo(
                  Icons.thermostat,
                  beach.temperature,
                ),
                _buildWeatherInfo(
                  Icons.waves,
                  beach.waveHeight,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              beach.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(text),
      ],
    );
  }

  Color _getSafetyColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'safe':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'dangerous':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Safety Map'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(20.5937, 78.9629), // Center of India
              zoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.beachsafety.app',
              ),
              MarkerLayer(
                markers: _beaches.map((beach) {
                  return Marker(
                    point: beach.position,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showBeachDetails(beach),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getSafetyColor(beach.safetyRating),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (_currentPosition != null)
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: () => _mapController.move(
                      _mapController.center,
                      _mapController.zoom + 1,
                    ),
                    backgroundColor: AppTheme.primaryColor,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    onPressed: () => _mapController.move(
                      _mapController.center,
                      _mapController.zoom - 1,
                    ),
                    backgroundColor: AppTheme.primaryColor,
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    backgroundColor: AppTheme.primaryColor,
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class BeachLocation {
  final String name;
  final LatLng position;
  final String safetyRating;
  final String description;
  final String weatherCondition;
  final String temperature;
  final String waveHeight;

  BeachLocation({
    required this.name,
    required this.position,
    required this.safetyRating,
    required this.description,
    required this.weatherCondition,
    required this.temperature,
    required this.waveHeight,
  });
}
