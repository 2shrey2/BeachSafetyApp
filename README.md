# Beach Safety App

A Flutter and FastAPI application for monitoring beach conditions and safety.

## Project Structure

- `app/` - FastAPI backend
- `beach_safety_app/` - Flutter frontend

## Quick Start Guide

For Windows users, simply run the provided batch script to start both backend and frontend:

```
start_app.bat
```

This will start:
- FastAPI backend at http://127.0.0.1:8000/api/v1
- Flutter web frontend at http://127.0.0.1:57681

## Setup Instructions (Manual)

### Prerequisites

- Python 3.8+ with pip
- Flutter SDK installed
- Chrome browser (for Flutter web)

### Backend Setup

1. Navigate to the backend directory:
   ```
   cd app
   ```

2. Create a virtual environment:
   ```
   python -m venv venv
   ```

3. Activate the virtual environment:
   - On Windows:
     ```
     venv\Scripts\activate
     ```
   - On macOS/Linux:
     ```
     source venv/bin/activate
     ```

4. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

5. Run the backend:
   ```
   uvicorn main:app --host 127.0.0.1 --port 8000 --reload
   ```
   
   The API will be available at: `http://127.0.0.1:8000/api/v1/`
   API documentation: `http://127.0.0.1:8000/docs`

### Frontend Setup

1. Navigate to the frontend directory:
   ```
   cd beach_safety_app
   ```

2. Get Flutter dependencies:
   ```
   flutter pub get
   ```

3. Run the Flutter app on Web:
   ```
   flutter run -d web-server --web-port 57681
   ```
   
   The web app will be available at: `http://127.0.0.1:57681`

## URL Configuration

This application is configured to work with the following URLs:

- Backend API: `http://127.0.0.1:8000/api/v1`
- API Documentation: `http://127.0.0.1:8000/docs`
- Frontend: `http://127.0.0.1:57681`

## Troubleshooting

### CORS Issues

If you encounter CORS issues:

1. Ensure the backend is running at `http://127.0.0.1:8000`
2. Verify that the CORS middleware in `app/main.py` includes your frontend URL
3. Check that the frontend URL in `beach_safety_app/lib/utils/cors_proxy.dart` matches your actual frontend URL

### Connection Issues

Use the built-in diagnostic tools:

1. Check the console logs when starting the app for connection status
2. Look for any errors related to backend connectivity

### Browser Console Errors

For CORS or API connection issues in the web frontend:
1. Open Chrome DevTools (F12)
2. Check the Console and Network tabs for error details

### Common Errors

1. **"Address already in use" error**
   - Another process might be using port 8000 or 57681
   - Find and stop the process, or use different ports

2. **"Cannot connect to backend" error**
   - Make sure the FastAPI backend is running
   - Check that the API URL in `app_constants.dart` is correct

3. **API not accessible at `/api/v1` path**
   - Verify settings.API_V1_STR in `app/core/config.py` is set to `/api/v1`
   - Check that the API router is correctly mounted in `app/main.py`
