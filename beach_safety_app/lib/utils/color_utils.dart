import 'package:flutter/material.dart';

/// Extension on Color to handle color manipulation consistently
extension ColorExtension on Color {
  /// Replaces the withValues method with withOpacity for compatibility
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromARGB(
      alpha != null ? (alpha * 255).round() : this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
} 