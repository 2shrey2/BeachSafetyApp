import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';

class BeachImage extends StatelessWidget {
  final String? imageUrl;
  final String beachId;
  final double height;
  final double width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const BeachImage({
    Key? key,
    required this.imageUrl,
    required this.beachId,
    this.height = 160,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get optimized URL
    final optimizedUrl = AppConstants.getOptimizedImageUrl(imageUrl);
    
    // For debugging
    print('BeachImage: Original URL: $imageUrl');
    print('BeachImage: Optimized URL: $optimizedUrl');
    
    // Decide if we should use asset or network image
    final useAsset = optimizedUrl.startsWith('assets/');
    
    Widget imageWidget;
    
    if (useAsset) {
      // Use asset image
      imageWidget = Image.asset(
        optimizedUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading asset image: $error');
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Icon(Icons.beach_access, size: 64),
          );
        },
      );
    } else {
      // Use cached network image
      imageWidget = CachedNetworkImage(
        imageUrl: optimizedUrl,
        height: height,
        width: width,
        fit: fit,
        httpHeaders: const {
          'Access-Control-Allow-Origin': '*',
          'Accept': 'image/*',
          'Referrer-Policy': 'no-referrer',
        },
        cacheKey: 'beach_${beachId}_${width.toInt()}',
        maxHeightDiskCache: (height * 2).toInt(),
        maxWidthDiskCache: (width * 2).toInt(),
        useOldImageOnUrlChange: true,
        fadeInDuration: Duration.zero,
        placeholder: (context, url) {
          print('Loading image from URL: $url');
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorWidget: (context, url, error) {
          print('Error loading image: $error for URL: $url');
          // Try to load a fallback image
          return Image.asset(
            AppConstants.defaultBeachImage,
            height: height,
            width: width,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: height,
                width: width,
                color: Colors.grey[200],
                child: const Icon(Icons.beach_access, size: 64),
              );
            },
          );
        },
      );
    }
    
    // Apply border radius if provided
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
} 