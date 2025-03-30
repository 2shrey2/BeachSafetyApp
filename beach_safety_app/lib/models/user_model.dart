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
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
      location: json['location'],
      favoriteBeachIds: List<String>.from(json['favorite_beach_ids'] ?? []),
      notificationPreferences: Map<String, bool>.from(json['notification_preferences'] ?? {
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
      'name': name,
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