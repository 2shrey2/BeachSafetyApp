import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../providers/beach_provider.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    _loadNearbyBeaches();
  }

  Future<void> _loadNearbyBeaches() async {
    await Provider.of<BeachProvider>(context, listen: false).getNearbyBeaches();
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
          if (beachProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          final beaches = beachProvider.beaches;
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 100,
                  color: AppTheme.primaryColor.withOpacity(0.7),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Beach Map Coming Soon',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We found ${beaches.length} beaches near you',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadNearbyBeaches,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Nearby Beaches'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 