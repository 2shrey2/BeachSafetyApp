import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showLogo;
  final VoidCallback? onBackPressed;
  final double elevation;

  const AppHeader({
    super.key,
    this.title = '',
    this.actions,
    this.showBackButton = true,
    this.showLogo = true,
    this.onBackPressed,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      backgroundColor: AppTheme.primaryColor,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: showLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logos/app_logo_white.png',
                  height: 32,
                  width: 32,
                  errorBuilder: (context, error, stackTrace) {
                    // If logo can't be loaded, show text fallback
                    return Container();
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  title.isNotEmpty ? title : AppConstants.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
      centerTitle: true,
      actions: actions,
    );
  }
} 