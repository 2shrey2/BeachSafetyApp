class User {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final String? location;
  final List<String> favoriteBeachIds;
  final Map<String, bool> notificationPreferences;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.location,
    this.favoriteBeachIds = const [],
    this.notificationPreferences = const {
      'beach_warnings': true,
      'weather_updates': true,
      'safety_alerts': true,
    },
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle both API formats (with or without nested fields)
    final Map<String, dynamic> userData = json;
    
    return User(
      id: userData['id']?.toString() ?? '',
      email: userData['email'] ?? '',
      name: userData['full_name'] ?? userData['name'] ?? '',  // Try full_name first, then fallback to name
      profileImageUrl: userData['profile_image_url'],
      location: userData['location'],
      favoriteBeachIds: List<String>.from(userData['favorite_beach_ids'] ?? []),
      notificationPreferences: Map<String, bool>.from(userData['notification_preferences'] ?? {
        'beach_warnings': true,
        'weather_updates': true,
        'safety_alerts': true,
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': name,  // Changed from 'name' to 'full_name' to match backend
      'profile_image_url': profileImageUrl,
      'location': location,
      'favorite_beach_ids': favoriteBeachIds,
      'notification_preferences': notificationPreferences,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? location,
    List<String>? favoriteBeachIds,
    Map<String, bool>? notificationPreferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      location: location ?? this.location,
      favoriteBeachIds: favoriteBeachIds ?? this.favoriteBeachIds,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
    );
  }
} 