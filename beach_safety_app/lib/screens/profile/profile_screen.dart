import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_indicator.dart';
import 'package:flutter/foundation.dart';
import '../../constants/app_constants.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  bool _isEditing = false;
  Map<String, bool> _notificationPreferences = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _locationController = TextEditingController();
    
    // Load user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.getUserProfile();
    
    if (userProvider.user != null) {
      _nameController.text = userProvider.user!.name;
      _emailController.text = userProvider.user!.email;
      _locationController.text = userProvider.user!.location ?? '';
      
      setState(() {
        _notificationPreferences = Map.from(userProvider.user!.notificationPreferences);
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset fields if canceling edit
        final user = Provider.of<UserProvider>(context, listen: false).user;
        if (user != null) {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _locationController.text = user.location ?? '';
          _notificationPreferences = Map.from(user.notificationPreferences);
        }
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final success = await userProvider.updateUserProfile(
        name: _nameController.text,
        email: _emailController.text,
        location: _locationController.text,
        notificationPreferences: _notificationPreferences,
      );
      
      if (success) {
        setState(() {
          _isEditing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userProvider.error ?? 'Failed to update profile')),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: LoadingIndicator(),
            ),
          );
        }
        
        final user = userProvider.user;
        
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: const Center(
              child: Text('Unable to load profile. Please try again later.'),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _toggleEditMode,
                ),
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleEditMode,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card with User Info
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side - Profile Image
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: user.profileImageUrl != null
                                    ? NetworkImage(user.profileImageUrl!)
                                    : null,
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.7),
                                child: user.profileImageUrl == null
                                    ? Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 35,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          // Right side - User Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!_isEditing) ...[
                                  Text(
                                    _nameController.text,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        _emailController.text,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_locationController.text.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          _locationController.text,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ] else ...[
                                  _buildTextField(
                                    label: 'Name',
                                    controller: _nameController,
                                    enabled: _isEditing,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Email',
                                    controller: _emailController,
                                    enabled: _isEditing,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    label: 'Location',
                                    controller: _locationController,
                                    enabled: _isEditing,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Access Section
                  const Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.favorites);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.favorite,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Favorite Beaches',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notification Preferences Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notification Preferences',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildNotificationPreferenceToggle(
                            'Weather Updates',
                            'weatherUpdates',
                          ),
                          _buildNotificationPreferenceToggle(
                            'Safety Alerts',
                            'safetyAlerts',
                          ),
                          _buildNotificationPreferenceToggle(
                            'Beach Events',
                            'beachEvents',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings Section
                  _buildSettingsSection(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildNotificationPreferenceToggle(String title, String prefKey) {
    return SwitchListTile(
      title: Text(title),
      value: _notificationPreferences[prefKey] ?? false,
      onChanged: _isEditing
          ? (value) {
              setState(() {
                _notificationPreferences[prefKey] = value;
              });
            }
          : null,
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            title: 'My Favorites',
            icon: Icons.favorite,
            onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Notifications',
            icon: Icons.notifications,
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          _buildDivider(),
          _buildSettingItem(
            title: 'Logout',
            icon: Icons.exit_to_app,
            iconColor: Colors.red,
            onTap: () => _showLogoutDialog(),
            titleStyle: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      Color? iconColor,
      TextStyle? titleStyle}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: titleStyle,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _logout,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 