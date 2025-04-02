import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_theme.dart';
import '../models/beach_model.dart';
import '../utils/safety_utils.dart';
import 'beach_image.dart';

class BeachCard extends StatelessWidget {
  final Beach beach;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const BeachCard({
    Key? key,
    required this.beach,
    required this.onTap,
    required this.onFavoriteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get safety status from the beach
    String safetyStatus = beach.currentConditions?.safetyStatus ?? 'unknown';
    
    // Use SafetyUtils to get standardized color and display text
    Color safetyColor = SafetyUtils.getSafetyColor(safetyStatus);
    String safetyText = SafetyUtils.getSafetyDisplayText(safetyStatus);
    
    // Debug the safety status
    print("Beach ${beach.name}: Original status='$safetyStatus', Display text='$safetyText'");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beach Image with Favorite Button
              Stack(
                children: [
                  // Beach Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: BeachImage(
                      imageUrl: beach.imageUrl,
                      beachId: beach.id,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          beach.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: beach.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: onFavoriteTap,
                        iconSize: 24,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  
                  // Safety Status Indicator
                  if (beach.currentConditions != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        color: safetyColor.withOpacity(0.8),
                        child: Text(
                          safetyText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Beach Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Beach Name
                    Text(
                      beach.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            beach.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    // Rating or View Count
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (beach.rating != null) ...[
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppTheme.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            beach.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (beach.viewCount != null) ...[
                          const Icon(
                            Icons.visibility,
                            size: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${beach.viewCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 