# Beach Safety App Backend

This is the backend API for the Beach Safety App, built with FastAPI, PostgreSQL, and Redis.

## Features

- **StormGlass API Integration**: Fetches and processes marine weather data
- **Beach Safety Algorithm**: Analyzes weather conditions to determine safety levels
- **User Authentication**: Secure JWT-based authentication
- **Real-time Notifications**: Alerts users about dangerous conditions
- **Geospatial Queries**: Find beaches near user's location

## Tech Stack

- **FastAPI**: Modern, fast web framework for building APIs
- **PostgreSQL**: Relational database for storing app data
- **SQLAlchemy**: ORM for database interaction
- **Redis**: Caching for StormGlass API responses
- **APScheduler**: Background task scheduling
- **Pydantic**: Data validation and settings management
- **JWT Authentication**: Secure user authentication

## Project Structure

```
app/
├── api/                # API endpoints
│   ├── deps.py         # API dependencies
│   └── routes/         # API route handlers
├── core/               # Core application code
│   ├── auth.py         # Authentication utilities
│   └── config.py       # Application configuration
├── crud/               # Database CRUD operations
├── db/                 # Database configuration
│   ├── redis.py        # Redis client setup
│   └── session.py      # SQLAlchemy session setup
├── models/             # SQLAlchemy models
├── schemas/            # Pydantic schemas
├── services/           # Business logic services
│   ├── stormglass.py   # StormGlass API service
│   ├── suitability.py  # Beach suitability algorithm
│   └── notification.py # User notification service
├── tasks/              # Background tasks
│   ├── scheduler.py    # Task scheduler
│   └── weather.py      # Weather data fetch tasks
├── utils/              # Utility functions
└── main.py             # Application entry point
```

## Setup and Installation

### Prerequisites

- Python 3.8+
- PostgreSQL (optional, will use SQLite as fallback)
- Redis (optional, will use in-memory cache as fallback)

### Environment Setup

1. Clone the repository
```bash
git clone https://github.com/yourusername/beach-safety-app.git
cd beach-safety-app
```

2. Create and activate a virtual environment
```bash
python -m venv venv
# On Windows
venv\Scripts\activate
# On MacOS/Linux
source venv/bin/activate
```

3. Install dependencies
```bash
pip install -r requirements.txt
```

4. Create a `.env` file (copy from `.env.example` and update with your values)
```bash
cp .env.example .env
```

5. Set up PostgreSQL (recommended but optional)
   - Create a database for the application:
   ```sql
   CREATE DATABASE beach_safety_db;
   ```
   - Create a user and grant privileges:
   ```sql
   CREATE USER beachapp WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE beach_safety_db TO beachapp;
   ```
   - Update the connection details in the `.env` file:
   ```
   POSTGRES_SERVER=localhost
   POSTGRES_USER=beachapp
   POSTGRES_PASSWORD=your_password
   POSTGRES_DB=beach_safety_db
   POSTGRES_PORT=5432
   ```

   If PostgreSQL is not available, the application will automatically fall back to using SQLite.

6. Set up Redis (recommended but optional)
   - Make sure Redis is running (default: localhost:6379)
   - Update Redis settings in the `.env` file if needed
   
   If Redis is not available, the application will automatically use an in-memory cache.

7. Set up StormGlass API key (optional)
   - Sign up for an API key at https://stormglass.io/
   - Add the key to your `.env` file:
   ```
   STORMGLASS_API_KEY=your_key_here
   ```
   
   If no API key is provided, the application will use mock data.

### Running the Application

```bash
python run.py
```

The API will be available at http://localhost:8000

API documentation will be available at:
- http://localhost:8000/docs (Swagger UI)
- http://localhost:8000/redoc (ReDoc)

## API Endpoints

### Authentication
- `POST /api/v1/auth/register`: Register a new user
- `POST /api/v1/auth/login`: Login and get access token

### Beaches
- `GET /api/v1/beaches`: List beaches
- `GET /api/v1/beaches/{beach_id}`: Get beach details
- `GET /api/v1/beaches/{beach_id}/conditions`: Get current beach conditions
- `POST /api/v1/beaches/{beach_id}/favorite`: Add beach to favorites
- `DELETE /api/v1/beaches/{beach_id}/favorite`: Remove beach from favorites

### Weather
- `GET /api/v1/weather/beaches/{beach_id}`: Get weather data for a beach
- `GET /api/v1/weather/nearby`: Get conditions for nearby beaches

### User
- `GET /api/v1/users/me`: Get current user info
- `PUT /api/v1/users/me`: Update user info
- `PUT /api/v1/users/me/location`: Update user location
- `GET /api/v1/users/me/notifications`: Get user notifications

## Troubleshooting

### Database Connection Issues

1. **PostgreSQL Authentication Failed**
   - Check that PostgreSQL is running
   - Verify the username and password in the `.env` file
   - Make sure the specified database exists
   - The application will fall back to SQLite if PostgreSQL is unavailable

2. **Redis Connection Issues**
   - Check that Redis is running
   - Verify the Redis connection details in the `.env` file
   - The application will use an in-memory cache if Redis is unavailable

3. **Missing API Keys**
   - If the StormGlass API key is missing, the application will generate mock data

### First-time Setup

If you're starting with an empty database, you'll need to:

1. Create a first admin user through the registration endpoint
2. Add some initial beach data using the beaches API
3. Wait for the scheduled task to fetch weather data, or trigger it manually

## License

MIT 