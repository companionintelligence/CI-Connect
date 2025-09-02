import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';

/// Demo page showing CI-Server API notification integration
class NotificationDemoPage extends StatefulWidget {
  const NotificationDemoPage({super.key});

  @override
  State<NotificationDemoPage> createState() => _NotificationDemoPageState();
}

class _NotificationDemoPageState extends State<NotificationDemoPage> {
  NotificationService? _notificationService;
  final List<NotificationData> _notifications = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Create API client with CI-Server URL
      final apiClient = ApiClient(
        firestore: FirebaseFirestore.instance,
        ciServerUrl: 'https://api.ci-server.example.com', // Replace with actual URL
      );
      
      _notificationService = apiClient.createNotificationService();
      
      // Initialize and listen for notifications
      await _notificationService!.initialize();
      
      _notificationService!.messageStream.listen((notification) {
        setState(() {
          _notifications.insert(0, notification);
        });
      });
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize notifications: $e')),
      );
    }
  }

  Future<void> _loadPeople() async {
    if (_notificationService == null) return;
    
    try {
      final people = await _notificationService!.getPeople();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded ${people.length} people from CI-Server')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load people: $e')),
      );
    }
  }

  Future<void> _loadPlaces() async {
    if (_notificationService == null) return;
    
    try {
      final places = await _notificationService!.getPlaces();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded ${places.length} places from CI-Server')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load places: $e')),
      );
    }
  }

  Future<void> _loadThings() async {
    if (_notificationService == null) return;
    
    try {
      final things = await _notificationService!.getThings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded ${things.length} things from CI-Server')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load things: $e')),
      );
    }
  }

  @override
  void dispose() {
    _notificationService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CI-Server Notifications'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isInitialized ? Icons.check_circle : Icons.hourglass_empty,
                      color: _isInitialized ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isInitialized 
                          ? 'Connected to CI-Server' 
                          : 'Connecting to CI-Server...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // API endpoint buttons
            Text(
              'CI-Server API Endpoints',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isInitialized ? _loadPeople : null,
                  icon: const Icon(Icons.people),
                  label: const Text('People'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isInitialized ? _loadPlaces : null,
                  icon: const Icon(Icons.place),
                  label: const Text('Places'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isInitialized ? _loadThings : null,
                  icon: const Icon(Icons.category),
                  label: const Text('Things'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Notifications list
            Text(
              'Notifications (${_notifications.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _notifications.isEmpty
                  ? const Center(
                      child: Text('No notifications received yet...'),
                    )
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.notifications),
                            title: Text(notification.title),
                            subtitle: Text(notification.body),
                            trailing: notification.timestamp != null
                                ? Text(
                                    '${notification.timestamp!.hour}:${notification.timestamp!.minute.toString().padLeft(2, '0')}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}