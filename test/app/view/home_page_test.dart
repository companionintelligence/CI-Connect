import 'package:companion_connect/app/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('HomePage', () {
    testWidgets('renders title and feature cards', (tester) async {
      await tester.pumpApp(const HomePage());

      expect(find.text('Companion Connect'), findsOneWidget);
      expect(find.text('CI-Server Notifications'), findsOneWidget);
      expect(find.text('API Documentation'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows platform information', (tester) async {
      await tester.pumpApp(const HomePage());

      // Should show platform info
      expect(find.textContaining('Running on'), findsOneWidget);
    });

    testWidgets('can navigate to notifications page', (tester) async {
      await tester.pumpApp(const HomePage());

      // Tap on notifications card
      await tester.tap(find.text('CI-Server Notifications'));
      await tester.pumpAndSettle();

      // Should navigate to notifications page
      expect(find.text('CI-Server Notification Demo'), findsOneWidget);
    });

    testWidgets('shows coming soon for unimplemented features', (tester) async {
      await tester.pumpApp(const HomePage());

      // Tap on API Documentation
      await tester.tap(find.text('API Documentation'));
      await tester.pumpAndSettle();

      // Should show coming soon snackbar
      expect(find.text('API Documentation - Coming Soon!'), findsOneWidget);
    });
  });
}