import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/beach_provider.dart';
import '../../widgets/beach_card.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_indicator.dart';
import '../../screens/beach/beach_details_screen.dart';
import 'widgets/category_tab.dart';
import '../../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['Most Viewed', 'Nearby', 'Safest', 'Latest'];
  int _selectedCategoryIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Load beaches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    // Load user profile
    Provider.of<UserProvider>(context, listen: false).getUserProfile();
    
    // Load beaches
    final beachProvider = Provider.of<BeachProvider>(context, listen: false);
    await beachProvider.getBeaches(refresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      Provider.of<BeachProvider>(context, listen: false).getBeaches(
        refresh: true,
        searchQuery: query,
      );
    }
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });

    String? category;
    String? sortBy;

    switch (_categories[index]) {
      case 'Most Viewed':
        sortBy = 'view_count';
        break;
      case 'Nearby':
        // Nearby logic handled in provider
        break;
      case 'Safest':
        category = 'safe';
        break;
      case 'Latest':
        sortBy = 'created_at';
        break;
    }

    Provider.of<BeachProvider>(context, listen: false).getBeaches(
      refresh: true,
      category: category,
      sortBy: sortBy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final userName = userProvider.user?.name ?? 'User';
                              return Text(
                                'Hi, ${userName.isNotEmpty ? userName.split(' ').first : 'USER'} 👋',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              );
                            }
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Explore the world',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final user = userProvider.user;
                          return CircleAvatar(
                            radius: 20,
                            backgroundImage: user?.profileImageUrl != null
                              ? NetworkImage(user!.profileImageUrl!)
                              : AssetImage('assets/images/avatar.jpeg') as ImageProvider,
                          );
                        }
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search places',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.filter_list, color: AppTheme.primaryColor),
                          onPressed: () {
                            // Show filter options
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: _onSearchSubmitted,
                    ),
                  ),
                ],
              ),
            ),

            // Category Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular places',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // View all beaches
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),
            ),
            
            // Category Tabs
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return CategoryTab(
                    title: _categories[index],
                    isSelected: _selectedCategoryIndex == index,
                    onTap: () => _onCategorySelected(index),
                  );
                },
              ),
            ),

            // Beach List
            Expanded(
              child: Consumer<BeachProvider>(
                builder: (context, beachProvider, child) {
                  if (beachProvider.isLoading && beachProvider.beaches.isEmpty) {
                    return const Center(
                      child: LoadingIndicator(
                        message: "Loading beaches...",
                        withShimmer: true,
                      ),
                    );
                  }

                  if (beachProvider.beaches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppTheme.textLightColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No beaches found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try with different search criteria',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: beachProvider.beaches.length + (beachProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the end when loading more beaches
                      if (index == beachProvider.beaches.length) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            strokeWidth: 3,
                          ),
                        );
                      }

                      final beach = beachProvider.beaches[index];
                      return BeachCard(
                        beach: beach,
                        onTap: () {
                          AppRoutes.navigateToBeachDetails(context, beach.id);
                        },
                        onFavoriteTap: () {
                          beachProvider.toggleFavorite(beach.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 