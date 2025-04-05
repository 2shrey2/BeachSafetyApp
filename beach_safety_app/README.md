# Beach Safety App - Mobile Frontend

A modern cross-platform mobile application built with Flutter that provides real-time beach safety monitoring, weather updates, and personalized alerts. This is the frontend repository of the Beach Safety App project. For the backend implementation, please refer to the main project repository.

## Features

- **Real-time Beach Monitoring**
  - Live safety status updates
  - Current weather conditions
  - Wave and tide information
  - Beach crowd levels

- **Interactive Maps**
  - Google Maps integration
  - Nearby beaches discovery
  - Custom beach markers with status indicators
  - Location-based search and filtering

- **User Experience**
  - Seamless user authentication
  - Personalized beach favorites
  - Custom notification preferences
  - Intuitive material design interface

- **Performance Features**
  - Offline data access
  - Smart image caching
  - Background synchronization
  - Optimized map rendering
  - Responsive UI across devices

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **API Integration**: Dio/HTTP package
- **Maps**: Google Maps Flutter
- **Storage**: SharedPreferences
- **Image Handling**: Cached Network Image
- **Location Services**: GeoLocator
- **UI Components**: Material Design

## Project Structure

```
beach_safety_app/
├── lib/
│   ├── api/          # API integration layer
│   ├── components/   # Reusable UI widgets
│   ├── constants/    # App configurations
│   ├── models/       # Data models
│   ├── providers/    # State management
│   ├── screens/      # App screens
│   ├── services/     # Business logic
│   ├── utils/        # Helper functions
│   └── main.dart     # Entry point
├── assets/           # Static resources
├── test/            # Unit/widget tests
└── android/         # Android config
```

## Getting Started

### Prerequisites

- Flutter SDK (3.x or higher)
- Dart SDK (3.x or higher)
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/beach_safety_app.git
   cd beach_safety_app/beach_safety_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure environment:
   - Add your Google Maps API key in `android/app/src/main/AndroidManifest.xml`
   - Configure the backend URL in `lib/constants/app_constants.dart`

4. Run the app:
   ```bash
   flutter run
   ```

### Development Mode

For local development with web support:
```bash
flutter run -d chrome --web-renderer=html --web-hostname=127.0.0.1 --web-port=8080
```

## Building for Production

### Android Release
```bash
flutter build apk --release
```
Find the APK at: `build/app/outputs/flutter-apk/app-release.apk`

### iOS Release (macOS required)
```bash
flutter build ios --release
```

## Testing

Run the test suite:
```bash
flutter test
```

## Configuration

The app can be configured through `lib/constants/app_constants.dart`:
- API endpoints configuration
- Map default settings
- Feature flags
- Environment variables

## Key Dependencies

- `provider`: ^6.0.0 (State management)
- `google_maps_flutter`: ^2.5.0 (Maps)
- `dio`: ^5.0.0 (HTTP client)
- `shared_preferences`: ^2.2.0 (Storage)
- `cached_network_image`: ^3.3.0 (Image caching)
- `geolocator`: ^10.0.0 (Location)

## Performance Optimizations

- Efficient image caching system
- Optimized map marker rendering
- Background data synchronization
- Provider-based state management
- Configured ProGuard for Android

## Security Features

- Secure credential storage
- Protected API keys
- Network security configuration
- SSL certificate pinning

---
Note: This is the frontend component of the Beach Safety App. For the complete project including the backend implementation, please refer to the main project repository.
