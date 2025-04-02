import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/beach_model.dart';
import '../../providers/beach_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/safety_utils.dart';

class BeachDetailsScreen extends StatefulWidget {
  final String beachId;

  const BeachDetailsScreen({
    Key? key,
    required this.beachId,
  }) : super(key: key);

  @override
  State<BeachDetailsScreen> createState() => _BeachDetailsScreenState();
}

class _BeachDetailsScreenState extends State<BeachDetailsScreen> with AutomaticKeepAliveClientMixin {
  bool _isDetailsView = false;
  final _scrollController = ScrollController();
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchBeachDetails();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchBeachDetails() {
    // Use Future.microtask to avoid triggering during build
    Future.microtask(() {
      if (!_isDisposed && mounted) {
        Provider.of<BeachProvider>(context, listen: false).getBeachDetails(widget.beachId);
      }
    });
  }

  void _toggleView() {
    if (!_isDisposed && mounted) {
      setState(() {
        _isDetailsView = !_isDetailsView;
      });
      
      // Use post-frame callback to ensure scroll happens after rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed && _scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      body: Consumer<BeachProvider>(
        builder: (context, beachProvider, child) {
          if (beachProvider.isLoading && beachProvider.selectedBeach == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final beach = beachProvider.selectedBeach;
          if (beach == null) {
            return _buildErrorScreen();
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              // App Bar with Beach Image
              _buildAppBar(beach),
              
              // Content
              SliverPadding(
                padding: EdgeInsets.zero,
                sliver: SliverToBoxAdapter(
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Info Cards
                        if (beach.currentConditions != null)
                          _buildQuickInfoCards(beach),
                        
                        // Safety Status
                        if (beach.currentConditions != null)
                          _buildSafetyStatus(beach),
                          
                        // View Selector
                        _buildViewSelector(),
                        
                        // Content with AnimatedSwitcher
                        _isDetailsView
                            ? _buildDetailsSection(beach)
                            : _buildOverviewSection(beach),
                            
                        // Book Now Button
                        _buildBookNowButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection(Beach beach) {
    return Container(
      key: const ValueKey<String>('overview'),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(Beach beach) {
    return Container(
      key: const ValueKey<String>('details'),
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
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAppBar(Beach beach) {
    return SliverAppBar(
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
            if (mounted && !_isDisposed) {
              Provider.of<BeachProvider>(context, listen: false)
                  .toggleFavorite(beach.id);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            if (mounted && !_isDisposed) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Beach Image - Using standard Image instead of CachedNetworkImage for better stability
            Image.network(
              beach.imageUrl ?? 'https://via.placeholder.com/800x500?text=Beach',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.error, size: 50, color: Colors.grey),
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
            
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
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
                mainAxisSize: MainAxisSize.min,
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
    );
  }

  Widget _buildQuickInfoCards(Beach beach) {
    return Padding(
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
    );
  }

  Widget _buildSafetyStatus(Beach beach) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SafetyUtils.getSafetyColor(beach.currentConditions!.safetyStatus).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: SafetyUtils.getSafetyColor(beach.currentConditions!.safetyStatus),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SafetyUtils.getSafetyColor(beach.currentConditions!.safetyStatus),
                shape: BoxShape.circle,
              ),
              child: Icon(
                SafetyUtils.getSafetyIcon(beach.currentConditions!.safetyStatus),
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
                    'Current Status: ${SafetyUtils.formatSafetyStatus(beach.currentConditions!.safetyStatus)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: SafetyUtils.getSafetyColor(beach.currentConditions!.safetyStatus),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    SafetyUtils.getSafetyMessage(beach.currentConditions!.safetyStatus),
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
    );
  }

  Widget _buildViewSelector() {
    return Padding(
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
                      onTap: !_isDetailsView ? null : _toggleView,
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isDetailsView ? AppTheme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Overview',
                          style: TextStyle(
                            color: !_isDetailsView ? Colors.white : AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _isDetailsView ? null : _toggleView,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isDetailsView ? AppTheme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Details',
                          style: TextStyle(
                            color: _isDetailsView ? Colors.white : AppTheme.textSecondaryColor,
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
    );
  }

  Widget _buildBookNowButton() {
    return Padding(
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            mainAxisSize: MainAxisSize.min,
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
              color: AppTheme.primaryColor.withOpacity(0.1),
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

  Widget _buildErrorScreen() {
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
              color: Colors.red.withOpacity(0.7),
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
                'Could not load beach details',
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
} 