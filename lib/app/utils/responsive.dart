import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
}

/// Extension to add responsive utilities to BuildContext
extension ResponsiveContext on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Check if current screen is mobile size
  bool get isMobile => screenWidth < ResponsiveBreakpoints.tablet;
  
  /// Check if current screen is tablet size
  bool get isTablet => screenWidth >= ResponsiveBreakpoints.tablet && 
                      screenWidth < ResponsiveBreakpoints.desktop;
  
  /// Check if current screen is desktop size
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.desktop;
  
  /// Check if current screen is tablet or larger
  bool get isTabletOrLarger => screenWidth >= ResponsiveBreakpoints.tablet;
  
  /// Check if screen is in landscape orientation
  bool get isLandscape => screenWidth > screenHeight;
  
  /// Check if screen is in portrait orientation
  bool get isPortrait => screenHeight > screenWidth;
}

/// A responsive widget that builds different widgets based on screen size
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return desktop!;
    } else if (context.isTablet && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

/// A responsive layout widget that provides different layouts for different screen sizes
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobileBody,
    required this.tabletBody,
    this.desktopBody,
    super.key,
  });

  final Widget mobileBody;
  final Widget tabletBody;
  final Widget? desktopBody;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: mobileBody,
      tablet: tabletBody,
      desktop: desktopBody ?? tabletBody,
    );
  }
}