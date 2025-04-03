// This file contains imports and functions only used in web builds
import 'dart:ui_web' as ui_web;

// Configure web-specific settings
void configureWebSettings() {
  // Add any web-specific configuration here
  ui_web.bootstrapEngine();
} 