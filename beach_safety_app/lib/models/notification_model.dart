enum NotificationType {
  beachAlert,
  weatherUpdate,
  systemMessage,
  other
}

class UserNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;

  UserNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.data,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    NotificationType notificationType;
    
    switch (json['type']) {
      case 'beach_alert':
        notificationType = NotificationType.beachAlert;
        break;
      case 'weather_update':
        notificationType = NotificationType.weatherUpdate;
        break;
      case 'system_message':
        notificationType = NotificationType.systemMessage;
        break;
      default:
        notificationType = NotificationType.other;
    }
    
    return UserNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: notificationType,
      isRead: json['is_read'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    String typeString;
    
    switch (type) {
      case NotificationType.beachAlert:
        typeString = 'beach_alert';
        break;
      case NotificationType.weatherUpdate:
        typeString = 'weather_update';
        break;
      case NotificationType.systemMessage:
        typeString = 'system_message';
        break;
      default:
        typeString = 'other';
    }
    
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': typeString,
      'is_read': isRead,
      'data': data,
    };
  }

  UserNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return UserNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
} 