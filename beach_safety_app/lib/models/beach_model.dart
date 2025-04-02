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
      id: json['id'].toString(),
      name: json['name'],
      location: json['location'] ?? '${json['city'] ?? ''}, ${json['state'] ?? ''}',
      latitude: (json['latitude'] is String) 
          ? double.parse(json['latitude']) 
          : json['latitude'].toDouble(),
      longitude: (json['longitude'] is String) 
          ? double.parse(json['longitude']) 
          : json['longitude'].toDouble(),
      imageUrl: json['image_url'],
      description: json['description'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
      currentConditions: json['current_conditions'] != null
          ? BeachConditions.fromJson(json['current_conditions'])
          : null,
      viewCount: json['view_count'] != null 
          ? (json['view_count'] is String 
              ? int.tryParse(json['view_count']) 
              : json['view_count'])
          : null,
      rating: json['rating'] != null 
          ? (json['rating'] is String 
              ? double.tryParse(json['rating']) 
              : json['rating'].toDouble()) 
          : null,
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

  String get safetyStatus => currentConditions?.safetyStatus ?? 'unknown';
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
    // Helper function to convert any value to double safely
    double parseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }
    
    // Helper function to convert any value to int safely
    int parseToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }
    
    return BeachConditions(
      safetyStatus: json['safety_status'] ?? json['suitability_level'] ?? 'unknown',
      temperature: parseToDouble(json['temperature'] ?? json['water_temperature']).isFinite ? 
                   parseToDouble(json['temperature'] ?? json['water_temperature']) : 0.0,
      humidity: parseToInt(json['humidity'] ?? 50), // Default humidity if not provided
      windSpeed: parseToDouble(json['wind_speed']).isFinite ? 
                 parseToDouble(json['wind_speed']) : 0.0,
      windDirection: json['wind_direction'] ?? 'Unknown',
      waveHeight: parseToDouble(json['wave_height']).isFinite ? 
                  parseToDouble(json['wave_height']) : 0.0,
      waterQuality: json['water_quality'],
      timestamp: json['timestamp'] != null 
          ? (json['timestamp'] is String 
              ? DateTime.parse(json['timestamp']) 
              : DateTime.fromMillisecondsSinceEpoch(json['timestamp']))
          : DateTime.now(),
      additionalData: json['additional_data'] ?? {
        'safety_score': json['safety_score'],
        'warning_message': json['warning_message'],
      },
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