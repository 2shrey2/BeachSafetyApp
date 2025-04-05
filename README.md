# Beach Safety App

A comprehensive beach safety monitoring system that provides real-time updates about beach conditions, weather forecasts, and safety alerts. The application consists of a Flutter-based mobile frontend and a FastAPI-powered backend.

![Beach Safety App](beach_safety_app/assets/images/beach.jpg)

## Project Overview

Beach Safety App helps users make informed decisions about beach visits by providing:
- Real-time safety status of beaches
- Current weather and ocean conditions
- Crowd level monitoring
- Personalized alerts and notifications
- Interactive maps with nearby beach discovery

## System Architecture

The project follows a modern client-server architecture:

```
Beach Safety App/
├── beach_safety_app/    # Flutter Mobile Frontend
└── app/                 # FastAPI Backend
```

### Frontend (Flutter)
- Cross-platform mobile application
- Material Design UI/UX
- Offline-first architecture
- Real-time data synchronization
- Location-based services

### Backend (FastAPI)
- RESTful API architecture
- PostgreSQL database
- Redis caching
- JWT authentication
- Background task scheduling

## Tech Stack

### Mobile Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **Storage**: SharedPreferences
- **HTTP Client**: Dio
- **Image Caching**: Cached Network Image

### Backend
- **Framework**: FastAPI
- **Language**: Python 3.8+
- **Database**: PostgreSQL
- **Caching**: Redis
- **Task Scheduler**: APScheduler
- **Authentication**: JWT + Bcrypt
- **API Documentation**: OpenAPI/Swagger
- **Geolocation**: GeoPy

## Key Features

### Beach Monitoring
- Live safety status tracking
- Weather condition updates
- Wave and tide information
- Beach crowd monitoring
- Historical data analysis

### User Features
- User authentication and profiles
- Favorite beaches management
- Customizable alert preferences
- Location-based recommendations
- Offline data access

### Admin Features
- Safety status management
- Beach information updates
- User management
- Analytics dashboard
- System monitoring

## Getting Started

### Prerequisites
- Python 3.8+
- Flutter 3.x
- PostgreSQL
- Redis
- Git

### Backend Setup
1. Navigate to backend directory:
   ```bash
   cd app
   ```

2. Create and activate virtual environment:
   ```bash
   python -m venv venv
   source venv\Scripts\activate  # For Windows
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Configure environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configurations
   ```

5. Run migrations:
   ```bash
   alembic upgrade head
   ```

6. Start the server:
   ```bash
   python run.py
   ```

### Frontend Setup
1. Navigate to frontend directory:
   ```bash
   cd beach_safety_app
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Configure environment:
   - Update backend URL in constants

4. Run the app:
   ```bash
   flutter run
   ```

## Development

### Backend Development
- API documentation available at `/docs` or `/redoc`
- Run tests: `pytest`
- Code formatting: `black .`
- Linting: `flake8`

### Frontend Development
- Run tests: `flutter test`
- Build APK: `flutter build apk --release`
- Web development: `flutter run -d chrome`

## Deployment

### Backend Deployment
- Supports Docker containerization
- Can be deployed to any cloud platform
- Requires PostgreSQL and Redis instances
- Environment-specific configurations

### Frontend Deployment
- Android: Generate signed APK
- iOS: Deploy through App Store
- Web: Static file hosting

## Security Measures

- JWT-based authentication
- Password hashing
- API key protection
- SSL/TLS encryption
- Input validation
- Rate limiting
- CORS configuration

## Performance Optimizations

- Database query optimization
- Redis caching layer
- Image optimization
- Lazy loading
- Background sync
- Efficient state management

## Project Structure

```
BeachSafetyApp/
├── app/                    # Backend
│   ├── api/               # API endpoints
│   ├── core/              # Core functionality
│   ├── crud/              # Database operations
│   ├── db/                # Database models
│   ├── schemas/           # Pydantic schemas
│   └── services/          # Business logic
│
└── beach_safety_app/      # Frontend
    ├── lib/               # Dart source code
    ├── assets/            # Static assets
    ├── android/           # Android specific
    └── ios/               # iOS specific
```


## Acknowledgments

- Weather data providers
- Map service providers
