import 'package:companion_connect/home/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomePage', () {
    testWidgets('should display app title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Companion Connect'), findsOneWidget);
    });

    testWidgets('should show navigation bar on mobile portrait', (tester) async {
      // Set mobile portrait size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Should show bottom navigation bar
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('should show navigation rail on tablet', (tester) async {
      // Set tablet size
      await tester.binding.setSurfaceSize(const Size(800, 1024));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Should show navigation rail
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('should show drawer on mobile landscape', (tester) async {
      // Set mobile landscape size
      await tester.binding.setSurfaceSize(const Size(800, 400));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Should show drawer and no bottom navigation
      expect(find.byType(Drawer), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('should display welcome content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Welcome to Companion Connect'), findsOneWidget);
      expect(find.text('Your AI companion is ready to help you connect and communicate.'), findsOneWidget);
    });

    testWidgets('should display feature cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
    });

    testWidgets('should show feature cards in grid on tablet', (tester) async {
      // Set tablet size
      await tester.binding.setSurfaceSize(const Size(800, 1024));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Should use GridView for tablet
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should show feature cards in list on mobile portrait', (tester) async {
      // Set mobile portrait size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Should use ListView for mobile portrait
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should show feature cards in grid on mobile landscape', (tester) async {
      // Set mobile landscape size
      await tester.binding.setSurfaceSize(const Size(800, 400));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Should use GridView for mobile landscape
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should navigate between tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Tap on Explore tab (assuming it's available)
      await tester.tap(find.text('Explore').first);
      await tester.pumpAndSettle();

      expect(find.text('Explore content coming soon!'), findsOneWidget);
    });

    testWidgets('should show snackbar when feature card is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Tap on Chat feature card
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Chat feature coming soon!'), findsOneWidget);
    });
  });
}