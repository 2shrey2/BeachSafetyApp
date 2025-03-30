import '../models/beach_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

/// This class provides mock data for development and testing
/// before the real API is integrated.
class MockDataService {
  // Get a list of sample beaches
  static List<Beach> getMockBeaches() {
    return [
      Beach(
        id: '1',
        name: 'Andes Mountain',
        location: 'South America',
        latitude: -32.653197,
        longitude: -70.011547,
        imageUrl: 'https://images.unsplash.com/photo-1503614472-8c93d56e92ce?q=80&w=1000&auto=format&fit=crop',
        description: 'This vast mountain range is renowned for its remarkable diversity in terms of topography and climate. It features towering peaks, active volcanoes, and glaciers. The Andes Mountains span seven countries along the western coast of South America.',
        isFavorite: false,
        rating: 4.5,
        viewCount: 230,
        currentConditions: BeachConditions(
          safetyStatus: 'moderate',
          temperature: 16.5,
          humidity: 65,
          windSpeed: 12.3,
          windDirection: 'North-East',
          waveHeight: 1.2,
          waterQuality: 'Good',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ),
      Beach(
        id: '2',
        name: 'Mount Fuji',
        location: 'Tokyo, Japan',
        latitude: 35.3606,
        longitude: 138.7274,
        imageUrl: 'https://images.unsplash.com/photo-1578637387939-43c525550085?q=80&w=1000&auto=format&fit=crop',
        description: 'Mount Fuji is Japan\'s tallest peak and an active volcano. This iconic symbol of Japan has been a sacred site for centuries and inspires artists with its perfectly symmetrical cone shape. The mountain is surrounded by beautiful lakes and forests.',
        isFavorite: true,
        rating: 4.8,
        viewCount: 456,
        currentConditions: BeachConditions(
          safetyStatus: 'safe',
          temperature: 22.0,
          humidity: 58,
          windSpeed: 8.5,
          windDirection: 'South',
          waveHeight: 0.5,
          waterQuality: 'Excellent',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ),
      Beach(
        id: '3',
        name: 'Copacabana Beach',
        location: 'Rio de Janeiro, Brazil',
        latitude: -22.9698,
        longitude: -43.1834,
        imageUrl: 'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?q=80&w=1000&auto=format&fit=crop',
        description: 'Copacabana is one of the most famous beaches in the world. The 4km stretch of sand is lined with hotels, restaurants, bars, and shops. The beach is known for its lively atmosphere, beach sports, and the iconic black and white Portuguese stone promenade.',
        isFavorite: false,
        rating: 4.6,
        viewCount: 378,
        currentConditions: BeachConditions(
          safetyStatus: 'safe',
          temperature: 28.5,
          humidity: 72,
          windSpeed: 10.2,
          windDirection: 'East',
          waveHeight: 0.8,
          waterQuality: 'Good',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      ),
      Beach(
        id: '4',
        name: 'Bondi Beach',
        location: 'Sydney, Australia',
        latitude: -33.8915,
        longitude: 151.2767,
        imageUrl: 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?q=80&w=1000&auto=format&fit=crop',
        description: 'Bondi Beach is one of Australia\'s most famous beaches. The beach is known for its golden sand, turquoise waters, and excellent surfing conditions. It\'s a popular spot for swimming, surfing, and sunbathing, with a vibrant beach culture.',
        isFavorite: false,
        rating: 4.7,
        viewCount: 412,
        currentConditions: BeachConditions(
          safetyStatus: 'dangerous',
          temperature: 25.8,
          humidity: 68,
          windSpeed: 18.5,
          windDirection: 'South-East',
          waveHeight: 2.5,
          waterQuality: 'Fair',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ),
      Beach(
        id: '5',
        name: 'Waikiki Beach',
        location: 'Honolulu, Hawaii',
        latitude: 21.2765,
        longitude: -157.8271,
        imageUrl: 'https://images.unsplash.com/photo-1507695493113-c3cd4b37aaef?q=80&w=1000&auto=format&fit=crop',
        description: 'Waikiki Beach is a world-famous beach located on the south shore of Honolulu. The beach is known for its white sand, crystal clear waters, and stunning views of Diamond Head. It\'s a popular spot for swimming, surfing, and sunbathing.',
        isFavorite: true,
        rating: 4.9,
        viewCount: 589,
        currentConditions: BeachConditions(
          safetyStatus: 'moderate',
          temperature: 27.3,
          humidity: 75,
          windSpeed: 15.0,
          windDirection: 'North-West',
          waveHeight: 1.8,
          waterQuality: 'Excellent',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ),
      Beach(
        id: '6',
        name: 'Maldives Beach',
        location: 'Maldives',
        latitude: 3.2028,
        longitude: 73.2207,
        imageUrl: 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?q=80&w=1000&auto=format&fit=crop',
        description: 'The Maldives is known for its pristine white sand beaches, crystal clear turquoise waters, and abundant marine life. The beaches here are surrounded by coral reefs, making them perfect for snorkeling and diving.',
        isFavorite: false,
        rating: 4.9,
        viewCount: 623,
        currentConditions: BeachConditions(
          safetyStatus: 'safe',
          temperature: 29.5,
          humidity: 80,
          windSpeed: 9.8,
          windDirection: 'South-West',
          waveHeight: 0.6,
          waterQuality: 'Excellent',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ),
    ];
  }

  // Get mock user data
  static User getMockUser() {
    return User(
      id: 'user123',
      email: 'user@example.com',
      name: 'David Johnson',
      profileImageUrl: 'https://ui-avatars.com/api/?name=David+Johnson&background=random',
      location: 'New York, USA',
      favoriteBeachIds: ['2', '5'],
      notificationPreferences: {
        'beach_warnings': true,
        'weather_updates': true,
        'safety_alerts': true,
      },
    );
  }

  // Get mock notifications
  static List<UserNotification> getMockNotifications() {
    return [
      UserNotification(
        id: 'notif1',
        title: 'Dangerous Conditions',
        message: 'Bondi Beach has been marked as dangerous due to high waves and strong currents.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.beachAlert,
        isRead: false,
        data: {
          'beachId': '4',
        },
      ),
      UserNotification(
        id: 'notif2',
        title: 'Weather Update',
        message: 'Weather at Mount Fuji is improving. The beach is now marked as safe.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.weatherUpdate,
        isRead: true,
        data: {
          'beachId': '2',
        },
      ),
      UserNotification(
        id: 'notif3',
        title: 'Favorite Beach Update',
        message: 'Waikiki Beach conditions have changed from safe to moderate. Exercise caution.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.systemMessage,
        isRead: true,
        data: {
          'beachId': '5',
        },
      ),
    ];
  }
} 