class Beach {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String description;
  final bool isFavorite;
  final BeachConditions? currentConditions;
  final int? viewCount;
  final double? rating;

  Beach({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.description,
    this.isFavorite = false,
    this.currentConditions,
    this.viewCount,
    this.rating,
  });

  factory Beach.fromJson(Map<String, dynamic> json) {
    return Beach(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      imageUrl: json['image_url'],
      description: json['description'],
      isFavorite: json['is_favorite'] ?? false,
      currentConditions: json['current_conditions'] != null
          ? BeachConditions.fromJson(json['current_conditions'])
          : null,
      viewCount: json['view_count'],
      rating: json['rating'] != null ? json['rating'].toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'description': description,
      'is_favorite': isFavorite,
      'current_conditions': currentConditions?.toJson(),
      'view_count': viewCount,
      'rating': rating,
    };
  }

  Beach copyWith({
    String? id,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? description,
    bool? isFavorite,
    BeachConditions? currentConditions,
    int? viewCount,
    double? rating,
  }) {
    return Beach(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      currentConditions: currentConditions ?? this.currentConditions,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
    );
  }
}

class BeachConditions {
  final String safetyStatus; // 'safe', 'moderate', 'dangerous', 'closed'
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final double waveHeight;
  final String? waterQuality;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  BeachConditions({
    required this.safetyStatus,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.waveHeight,
    this.waterQuality,
    required this.timestamp,
    this.additionalData,
  });

  factory BeachConditions.fromJson(Map<String, dynamic> json) {
    return BeachConditions(
      safetyStatus: json['safety_status'],
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'],
      windSpeed: json['wind_speed'].toDouble(),
      windDirection: json['wind_direction'],
      waveHeight: json['wave_height'].toDouble(),
      waterQuality: json['water_quality'],
      timestamp: DateTime.parse(json['timestamp']),
      additionalData: json['additional_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'safety_status': safetyStatus,
      'temperature': temperature,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'wind_direction': windDirection,
      'wave_height': waveHeight,
      'water_quality': waterQuality,
      'timestamp': timestamp.toIso8601String(),
      'additional_data': additionalData,
    };
  }
} 