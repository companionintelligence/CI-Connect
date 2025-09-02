import 'package:companion_connect/app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveBreakpoints', () {
    test('should have correct breakpoint values', () {
      expect(ResponsiveBreakpoints.mobile, 480);
      expect(ResponsiveBreakpoints.tablet, 768);
      expect(ResponsiveBreakpoints.desktop, 1024);
    });
  });

  group('ResponsiveContext Extension', () {
    testWidgets('should correctly identify mobile screens', (tester) async {
      // Create a widget with mobile screen size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      expect(capturedContext.screenWidth, 400);
      expect(capturedContext.screenHeight, 800);
      expect(capturedContext.isMobile, isTrue);
      expect(capturedContext.isTablet, isFalse);
      expect(capturedContext.isDesktop, isFalse);
      expect(capturedContext.isTabletOrLarger, isFalse);
      expect(capturedContext.isPortrait, isTrue);
      expect(capturedContext.isLandscape, isFalse);
    });

    testWidgets('should correctly identify tablet screens', (tester) async {
      // Create a widget with tablet screen size
      await tester.binding.setSurfaceSize(const Size(800, 1024));
      
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      expect(capturedContext.screenWidth, 800);
      expect(capturedContext.screenHeight, 1024);
      expect(capturedContext.isMobile, isFalse);
      expect(capturedContext.isTablet, isTrue);
      expect(capturedContext.isDesktop, isFalse);
      expect(capturedContext.isTabletOrLarger, isTrue);
      expect(capturedContext.isPortrait, isTrue);
      expect(capturedContext.isLandscape, isFalse);
    });

    testWidgets('should correctly identify landscape orientation', (tester) async {
      // Create a widget with landscape screen size
      await tester.binding.setSurfaceSize(const Size(1024, 600));
      
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );

      expect(capturedContext.screenWidth, 1024);
      expect(capturedContext.screenHeight, 600);
      expect(capturedContext.isDesktop, isTrue);
      expect(capturedContext.isLandscape, isTrue);
      expect(capturedContext.isPortrait, isFalse);
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('should build mobile widget for mobile screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            mobile: const Text('Mobile'),
            tablet: const Text('Tablet'),
            desktop: const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should build tablet widget for tablet screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1024));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            mobile: const Text('Mobile'),
            tablet: const Text('Tablet'),
            desktop: const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should fallback to mobile when tablet is null', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1024));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            mobile: const Text('Mobile'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
    });
  });

  group('ResponsiveLayout', () {
    testWidgets('should show mobile layout for mobile screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobileBody: const Text('Mobile Layout'),
            tabletBody: const Text('Tablet Layout'),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);
    });

    testWidgets('should show tablet layout for tablet screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1024));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobileBody: const Text('Mobile Layout'),
            tabletBody: const Text('Tablet Layout'),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsOneWidget);
    });
  });
}