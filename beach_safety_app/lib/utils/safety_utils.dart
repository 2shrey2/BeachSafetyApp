import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class SafetyUtils {
  /// Standardize safety status to one of: 'safe', 'moderate', 'dangerous', 'closed', 'unknown'
  static String standardizeSafetyStatus(String status) {
    final String lowerStatus = status.toLowerCase();
    
    // Map various status values to standardized ones
    if (lowerStatus.contains('safe') || lowerStatus == 'good') {
      return 'safe';
    } else if (lowerStatus.contains('moderate') || lowerStatus == 'warning') {
      return 'moderate';
    } else if (lowerStatus.contains('danger') || lowerStatus == 'high' || lowerStatus == 'severe') {
      return 'dangerous';
    } else if (lowerStatus.contains('closed')) {
      return 'closed';
    }
    
    return 'unknown';
  }
  
  /// Get color for safety status
  static Color getSafetyColor(String status) {
    final String standardStatus = standardizeSafetyStatus(status);
    
    switch (standardStatus) {
      case 'safe':
        return AppTheme.successColor;
      case 'moderate':
        return AppTheme.warningColor;
      case 'dangerous':
        return AppTheme.dangerColor;
      case 'closed':
      case 'unknown':
      default:
        return AppTheme.textLightColor;
    }
  }
  
  /// Get user-friendly display text for safety status
  static String getSafetyDisplayText(String status) {
    final String standardStatus = standardizeSafetyStatus(status);
    
    switch (standardStatus) {
      case 'safe':
        return 'SAFE';
      case 'moderate':
        return 'MODERATE';
      case 'dangerous':
        return 'DANGEROUS';
      case 'closed':
        return 'CLOSED';
      case 'unknown':
      default:
        return 'UNKNOWN';
    }
  }
  
  /// Get icon for safety status
  static IconData getSafetyIcon(String safetyStatus) {
    final String standardStatus = standardizeSafetyStatus(safetyStatus);
    
    switch (standardStatus) {
      case 'safe':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning;
      case 'dangerous':
        return Icons.dangerous;
      case 'closed':
        return Icons.do_not_disturb;
      case 'unknown':
      default:
        return Icons.help_outline;
    }
  }
  
  /// Format safety status for display (capitalize first letter)
  static String formatSafetyStatus(String safetyStatus) {
    final String standardStatus = standardizeSafetyStatus(safetyStatus);
    return standardStatus.substring(0, 1).toUpperCase() + standardStatus.substring(1);
  }
  
  /// Get safety message for status
  static String getSafetyMessage(String safetyStatus) {
    final String standardStatus = standardizeSafetyStatus(safetyStatus);
    
    switch (standardStatus) {
      case 'safe':
        return 'The beach is safe for swimming and water activities.';
      case 'moderate':
        return 'Exercise caution. Conditions may change rapidly.';
      case 'dangerous':
        return 'Swimming not recommended. High risk conditions.';
      case 'closed':
        return 'The beach is temporarily closed to the public.';
      case 'unknown':
      default:
        return 'Status information unavailable.';
    }
  }
} 