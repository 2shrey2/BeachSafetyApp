@echo off
echo Starting Beach Safety App in development mode...
echo.
echo NOTE: Make sure your backend server is running at http://127.0.0.1:8000
echo.
flutter run -d chrome --web-renderer=html --web-hostname=127.0.0.1 --web-port=8080 