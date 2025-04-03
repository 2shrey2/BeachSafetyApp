import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/beach_model.dart';
import '../../providers/beach_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = true;
  List<Beach> _favoriteBeaches = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final beachProvider = Provider.of<BeachProvider>(context, listen: false);
      await beachProvider.getFavoriteBeaches();
      
      setState(() {
        _favoriteBeaches = beachProvider.favoriteBeaches;
        _isLoading = false;
      });
      
      print('Loaded ${_favoriteBeaches.length} favorite beaches');
      for (final beach in _favoriteBeaches) {
        print('Favorite beach: ${beach.name}, image: ${beach.imageUrl}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading favorites: $e')),
      );
    }
  }

  void _removeFromFavorites(Beach beach) async {
    try {
      await Provider.of<BeachProvider>(context, listen: false).toggleFavorite(beach.id);
      setState(() {
        _favoriteBeaches.removeWhere((item) => item.id == beach.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${beach.name} removed from favorites'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              await Provider.of<BeachProvider>(context, listen: false).toggleFavorite(beach.id);
              setState(() {
                _loadFavorites();
              });
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing from favorites: $e')),
      );
    }
  }

  void _navigateToBeachDetails(Beach beach) {
    Navigator.pushNamed(
      context, 
      '/beach-details',
      arguments: beach.id,
    ).then((_) => _loadFavorites()); // Refresh when coming back
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Favorite Beaches Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Add beaches to your favorites to access them quickly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            icon: const Icon(Icons.search),
            label: const Text('Explore Beaches'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Beaches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: _isLoading
            ? _buildLoadingState()
            : _favoriteBeaches.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favoriteBeaches.length,
                    itemBuilder: (context, index) {
                      final beach = _favoriteBeaches[index];
                      return _buildFavoriteItem(beach);
                    },
                  ),
      ),
    );
  }

  Widget _buildFavoriteItem(Beach beach) {
    final safetyColor = _getSafetyColor(beach.currentConditions?.safetyStatus ?? 'unknown');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(beach.id),
        background: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Remove from Favorites?'),
                content: Text('Are you sure you want to remove ${beach.name} from favorites?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('REMOVE'),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          _removeFromFavorites(beach);
        },
        child: InkWell(
          onTap: () => _navigateToBeachDetails(beach),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: beach.imageUrl != null && beach.imageUrl!.isNotEmpty
                              ? (beach.imageUrl!.startsWith('assets/')
                                  ? Image.asset(
                                      beach.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Error loading asset image in favorites: $error');
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.beach_access, size: 36),
                                        );
                                      },
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: beach.imageUrl!,
                                      fit: BoxFit.cover,
                                      httpHeaders: const {
                                        'Access-Control-Allow-Origin': '*',
                                        'Accept': 'image/*',
                                      },
                                      placeholder: (context, url) {
                                        print('Loading favorite image from URL: $url');
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                      errorWidget: (context, url, error) {
                                        print('Error loading favorite image: $error for URL: $url');
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.beach_access, size: 36),
                                        );
                                      },
                                    ))
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.beach_access, size: 36),
                                ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        beach.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  beach.location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: safetyColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getSafetyIcon(
                                              beach.currentConditions?.safetyStatus ?? 'unknown',
                                            ),
                                            size: 14,
                                            color: safetyColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            beach.currentConditions?.safetyStatus.toUpperCase() ??
                                                'UNKNOWN',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: safetyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (beach.rating != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 14,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            beach.rating!.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSafetyColor(String safetyStatus) {
    switch (safetyStatus.toLowerCase()) {
      case 'safe':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'caution':
        return Colors.orange;
      case 'dangerous':
        return Colors.red;
      case 'closed':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getSafetyIcon(String safetyStatus) {
    switch (safetyStatus.toLowerCase()) {
      case 'safe':
        return Icons.check_circle;
      case 'moderate':
      case 'caution':
        return Icons.warning;
      case 'dangerous':
      case 'closed':
        return Icons.dangerous;
      default:
        return Icons.help;
    }
  }
} 