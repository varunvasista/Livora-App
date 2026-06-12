import 'package:flutter/material.dart';

class ResponsiveHelper {
  final BuildContext context;
  late MediaQueryData mediaQuery;
  late double screenWidth;
  late double screenHeight;

  ResponsiveHelper(this.context) {
    mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
  }

  // Breakpoints
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // Scale factor based on standard mobile width of 375
  double get scaleFactor {
    if (isMobile) {
      return (screenWidth / 375.0).clamp(0.85, 1.15);
    } else if (isTablet) {
      return 1.05;
    } else {
      return 1.1;
    }
  }

  // Dynamic font sizing
  double text(double size) => size * scaleFactor;

  // Dynamic spacing/padding
  double space(double value) => value * scaleFactor;

  // Screen horizontal padding
  double get screenPaddingHorizontal {
    if (isMobile) {
      return (screenWidth < 360 ? 8.0 : 16.0) * scaleFactor;
    } else if (isTablet) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  // Screen vertical padding
  double get screenPaddingVertical {
    if (isMobile) {
      return (screenHeight < 600 ? 8.0 : 16.0) * scaleFactor;
    } else if (isTablet) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  // Card internal horizontal padding
  double get cardPaddingHorizontal {
    if (isMobile) {
      return (screenWidth < 360 ? 12.0 : (screenWidth < 400 ? 16.0 : 22.0)) * scaleFactor;
    } else if (isTablet) {
      return 26.0;
    } else {
      return 28.0;
    }
  }

  // Card internal vertical padding
  double get cardPaddingVertical {
    if (isMobile) {
      return (screenHeight < 600 ? 14.0 : 26.0) * scaleFactor;
    } else if (isTablet) {
      return 30.0;
    } else {
      return 32.0;
    }
  }

  // Responsive max content width for the main form card
  double get maxContentWidth {
    if (isMobile) {
      return (screenWidth - screenPaddingHorizontal * 2).clamp(240.0, 420.0);
    } else if (isTablet) {
      return 450.0;
    } else {
      return 480.0;
    }
  }
}
