import 'dart:io';
import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:companion_connect/l10n/l10n.dart';
import 'package:companion_connect/notifications/notifications.dart';
import 'package:flutter/material.dart';

/// Main home page with navigation to different features
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Companion Connect',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'A Flutter application that provides seamless connectivity to the Companion Intelligence Server',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            
            // Features grid
            Expanded(
              child: GridView.count(
                crossAxisCount: _getCrossAxisCount(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _FeatureCard(
                    title: 'CI-Server Notifications',
                    description: 'Real-time notifications and API connectivity testing',
                    icon: Icons.notifications,
                    onTap: () => _navigateToNotifications(context),
                  ),
                  if (_supportsIOSImport())
                    _FeatureCard(
                      title: 'iOS Import',
                      description: 'Import contacts, messages, and media from iOS backups',
                      icon: Icons.phone_iphone,
                      onTap: () => _navigateToIOSImport(context),
                    ),
                  _FeatureCard(
                    title: 'API Documentation',
                    description: 'View CI-Server API endpoints and documentation',
                    icon: Icons.api,
                    onTap: () => _showComingSoon(context, 'API Documentation'),
                  ),
                  _FeatureCard(
                    title: 'Settings',
                    description: 'Configure server connections and preferences',
                    icon: Icons.settings,
                    onTap: () => _showComingSoon(context, 'Settings'),
                  ),
                ],
              ),
            ),
            
            // Platform info
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      _getPlatformIcon(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Running on ${_getPlatformName()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_supportsIOSImport()) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'iOS Import Supported',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  bool _supportsIOSImport() {
    return Platform.isMacOS || Platform.isWindows;
  }

  IconData _getPlatformIcon() {
    if (Platform.isMacOS) return Icons.laptop_mac;
    if (Platform.isWindows) return Icons.laptop_windows;
    if (Platform.isIOS) return Icons.phone_iphone;
    if (Platform.isAndroid) return Icons.phone_android;
    return Icons.computer;
  }

  String _getPlatformName() {
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown Platform';
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const NotificationDemoPage(),
      ),
    );
  }

  void _navigateToIOSImport(BuildContext context) {
    try {
      IOSImportService.validatePlatform();
      
      // Create CI-Server client (you would get these from app config)
      final ciServerClient = CIServerClient(
        dio: Dio(),
        baseUrl: 'https://api.ci-server.example.com',
        // apiKey: 'your-api-key', // Add API key if needed
      );
      
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => IOSImportPage(
            ciServerClient: ciServerClient,
            studioId: 'default-studio', // Replace with actual studio ID
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('iOS Import not supported: $e')),
      );
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature - Coming Soon!')),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}