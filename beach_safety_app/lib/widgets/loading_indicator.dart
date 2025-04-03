import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final String? message;
  final bool withShimmer;

  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.message,
    this.withShimmer = false,
  });

  @override
  Widget build(BuildContext context) {
    if (withShimmer) {
      return _buildShimmerLoading();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  strokeWidth: 3,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerItem(height: 100, width: double.infinity),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildShimmerItem(height: 20)),
              const SizedBox(width: 16),
              Expanded(child: _buildShimmerItem(height: 20)),
            ],
          ),
          const SizedBox(height: 16),
          _buildShimmerItem(height: 20, width: double.infinity),
          const SizedBox(height: 8),
          _buildShimmerItem(height: 20, width: 200),
        ],
      ),
    );
  }

  Widget _buildShimmerItem({required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.withValues(alpha: 0.1),
            Colors.grey.withValues(alpha: 0.2),
            Colors.grey.withValues(alpha: 0.3),
            Colors.grey.withValues(alpha: 0.2),
            Colors.grey.withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }
} 