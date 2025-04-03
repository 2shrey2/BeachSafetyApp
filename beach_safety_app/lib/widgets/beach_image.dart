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
    super.key,
    required this.imageUrl,
    required this.beachId,
    this.height = 160,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Get optimized URL
    final optimizedUrl = AppConstants.getOptimizedImageUrl(imageUrl);
    
    // For debugging
    print('BeachImage: Original URL: $imageUrl');
    print('BeachImage: Optimized URL: $optimizedUrl');
    
    // Create a constrained box to enforce size limits
    Widget imageContainer = SizedBox(
      height: height,
      width: width,
      child: _buildImageWidget(optimizedUrl),
    );
    
    // Apply border radius if provided
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageContainer,
      );
    }
    
    return imageContainer;
  }
  
  Widget _buildImageWidget(String imageUrl) {
    // Decide if we should use asset or network image
    final useAsset = imageUrl.startsWith('assets/');
    
    if (useAsset) {
      // Use asset image
      return Image.asset(
        imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading asset image: $error');
          return _buildPlaceholder();
        },
      );
    } else {
      // Use cached network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        httpHeaders: const {
          'Access-Control-Allow-Origin': '*',
          'Accept': 'image/*',
          'Referrer-Policy': 'no-referrer',
        },
        cacheKey: 'beach_${beachId}_${width.toInt()}',
        maxHeightDiskCache: height.isFinite ? (height * 2).toInt() : 320,
        maxWidthDiskCache: width.isFinite ? (width * 2).toInt() : 480,
        useOldImageOnUrlChange: true,
        fadeInDuration: Duration.zero,
        placeholder: (context, url) {
          print('Loading image from URL: $url');
          return _buildLoadingPlaceholder();
        },
        errorWidget: (context, url, error) {
          print('Error loading image: $error for URL: $url');
          return _buildPlaceholder();
        },
      );
    }
  }
  
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.beach_access, size: 64, color: Colors.grey),
      ),
    );
  }
  
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 