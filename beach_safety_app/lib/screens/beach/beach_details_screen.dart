import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/beach_model.dart';
import '../../providers/beach_provider.dart';
import '../../widgets/loading_indicator.dart';

class BeachDetailsScreen extends StatefulWidget {
  final String beachId;

  const BeachDetailsScreen({
    Key? key,
    required this.beachId,
  }) : super(key: key);

  @override
  State<BeachDetailsScreen> createState() => _BeachDetailsScreenState();
}

class _BeachDetailsScreenState extends State<BeachDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMapView = false;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Fetch beach details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BeachProvider>(context, listen: false).getBeachDetails(widget.beachId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        // If we're not on the first tab, go to first tab instead of exiting
        if (_tabController.index != 0) {
          setState(() => _tabController.index = 0);
          _tabController.animateTo(0);
          return;
        }
        
        // Double back to exit
        final now = DateTime.now();
        if (_lastBackPressTime == null || 
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      canPop: false,
      child: Scaffold(
        body: Consumer<BeachProvider>(
          builder: (context, beachProvider, child) {
            if (beachProvider.isLoading && beachProvider.selectedBeach == null) {
              return Center(
                child: LoadingIndicator(
                  message: 'Loading beach details...',
                ),
              );
            }

            final beach = beachProvider.selectedBeach;
            if (beach == null) {
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: const Text('Beach Details'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Beach not found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          beachProvider.error ?? 'Could not load beach details',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                // App Bar with Beach Image
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  backgroundColor: AppTheme.primaryColor,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        beach.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Provider.of<BeachProvider>(context, listen: false)
                            .toggleFavorite(beach.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share feature coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Beach Image
                        CachedNetworkImage(
                          imageUrl: beach.imageUrl ?? 'https://picsum.photos/400/250?blur=2',
                          fit: BoxFit.cover,
                          httpHeaders: const {'Access-Control-Allow-Origin': '*'},
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.beach_access, size: 64),
                          ),
                        ),
                        
                        // Gradient overlay for better text visibility
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                        
                        // Beach name and location at bottom
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                beach.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      beach.location,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Beach Information
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Info Cards
                      if (beach.currentConditions != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              _buildInfoCard(
                                icon: Icons.waves,
                                value: '${beach.currentConditions!.waveHeight} m',
                                label: 'Waves',
                              ),
                              _buildInfoCard(
                                icon: Icons.thermostat,
                                value: '${beach.currentConditions!.temperature}˚ C',
                                label: 'Temp',
                              ),
                              _buildInfoCard(
                                icon: Icons.air,
                                value: '${beach.currentConditions!.windSpeed} km/h',
                                label: 'Wind',
                              ),
                              if (beach.rating != null)
                                _buildInfoCard(
                                  icon: Icons.star,
                                  value: beach.rating!.toStringAsFixed(1),
                                  label: 'Rating',
                                  valueColor: AppTheme.accentColor,
                                ),
                            ],
                          ),
                        ),
                      
                      // Safety Status
                      if (beach.currentConditions != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getSafetyColor(beach.currentConditions!.safetyStatus).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getSafetyColor(beach.currentConditions!.safetyStatus),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getSafetyColor(beach.currentConditions!.safetyStatus),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getSafetyIcon(beach.currentConditions!.safetyStatus),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Current Status: ${_formatSafetyStatus(beach.currentConditions!.safetyStatus)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _getSafetyColor(beach.currentConditions!.safetyStatus),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getSafetyMessage(beach.currentConditions!.safetyStatus),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Last Updated: ${DateFormat('MMM dd, yyyy • HH:mm').format(beach.currentConditions!.timestamp)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.textLightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                      // View Selector
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isMapView = false;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: !_isMapView ? AppTheme.primaryColor : Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Overview',
                                            style: TextStyle(
                                              color: !_isMapView ? Colors.white : AppTheme.textSecondaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isMapView = true;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _isMapView ? AppTheme.primaryColor : Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Details',
                                            style: TextStyle(
                                              color: _isMapView ? Colors.white : AppTheme.textSecondaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Tab Content
                      !_isMapView
                          ? _buildOverviewSection(beach)
                          : _buildDetailsSection(beach),
                          
                      // Book Now Button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () {
                            // Implement booking functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Book Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return Expanded(
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: valueColor ?? AppTheme.textPrimaryColor,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOverviewSection(Beach beach) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            beach.description,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Facilities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildFacilities(),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Recommended Activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildActivities(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(Beach beach) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Weather',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (beach.currentConditions != null) ...[
            _buildDetailRow(
              icon: Icons.thermostat,
              title: 'Temperature',
              value: '${beach.currentConditions!.temperature}° C',
            ),
            _buildDetailRow(
              icon: Icons.water_drop,
              title: 'Humidity',
              value: '${beach.currentConditions!.humidity}%',
            ),
            _buildDetailRow(
              icon: Icons.air,
              title: 'Wind',
              value: '${beach.currentConditions!.windSpeed} km/h, ${beach.currentConditions!.windDirection}',
            ),
            _buildDetailRow(
              icon: Icons.waves,
              title: 'Wave Height',
              value: '${beach.currentConditions!.waveHeight} m',
            ),
            if (beach.currentConditions!.waterQuality != null)
              _buildDetailRow(
                icon: Icons.opacity,
                title: 'Water Quality',
                value: beach.currentConditions!.waterQuality!,
              ),
          ],
          
          const SizedBox(height: 24),
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Map View'),
              // In a real app, implement Google Maps here
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFacilities() {
    final facilities = [
      {'icon': Icons.wc, 'name': 'Restrooms'},
      {'icon': Icons.shower, 'name': 'Showers'},
      {'icon': Icons.restaurant, 'name': 'Food Vendors'},
      {'icon': Icons.local_parking, 'name': 'Parking'},
      {'icon': Icons.wheelchair_pickup, 'name': 'Accessibility'},
      {'icon': Icons.pets, 'name': 'Pet Friendly'},
    ];
    
    return facilities.map((facility) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              facility['icon'] as IconData,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              facility['name'] as String,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildActivities() {
    final activities = [
      {'icon': Icons.surfing, 'name': 'Surfing'},
      {'icon': Icons.pool, 'name': 'Swimming'},
      {'icon': Icons.kayaking, 'name': 'Kayaking'},
      {'icon': Icons.beach_access, 'name': 'Sunbathing'},
      {'icon': Icons.directions_walk, 'name': 'Walking'},
      {'icon': Icons.catching_pokemon, 'name': 'Snorkeling'},
    ];
    
    return activities.map((activity) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activity['icon'] as IconData,
              size: 16,
              color: AppTheme.accentColor,
            ),
            const SizedBox(width: 4),
            Text(
              activity['name'] as String,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getSafetyColor(String safetyStatus) {
    switch (safetyStatus) {
      case 'safe':
        return AppTheme.successColor;
      case 'moderate':
        return AppTheme.warningColor;
      case 'dangerous':
        return AppTheme.dangerColor;
      case 'closed':
      default:
        return AppTheme.textLightColor;
    }
  }

  IconData _getSafetyIcon(String safetyStatus) {
    switch (safetyStatus) {
      case 'safe':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning;
      case 'dangerous':
        return Icons.dangerous;
      case 'closed':
      default:
        return Icons.do_not_disturb;
    }
  }

  String _formatSafetyStatus(String safetyStatus) {
    return safetyStatus.substring(0, 1).toUpperCase() + safetyStatus.substring(1);
  }

  String _getSafetyMessage(String safetyStatus) {
    switch (safetyStatus) {
      case 'safe':
        return 'The beach is safe for swimming and water activities.';
      case 'moderate':
        return 'Exercise caution. Conditions may change rapidly.';
      case 'dangerous':
        return 'Swimming not recommended. High risk conditions.';
      case 'closed':
        return 'The beach is temporarily closed to the public.';
      default:
        return 'Status information unavailable.';
    }
  }
} 