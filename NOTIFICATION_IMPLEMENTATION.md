# CI-Connect Notification System

This implementation provides notification support for the CI-Connect Flutter application using the CI-Server API instead of Firebase Cloud Messaging.

## Architecture

### API Client Package (`packages/api_client`)

The API client package has been updated to support both Firebase (for existing functionality) and CI-Server HTTP endpoints:

- **NotificationService**: HTTP-based notification service that integrates with CI-Server API
- **ApiClient**: Enhanced to create notification service instances with configurable CI-Server URL
- **Minimal Firebase dependencies**: Removed firebase_messaging dependency while keeping other Firebase services

### CI-Server API Integration

The notification service integrates with the following CI-Server endpoints:

- **`/people`** - People endpoint for user/contact management
- **`/places`** - Places endpoint for location data
- **`/content`** - Content endpoint for notifications and content management
- **`/contact`** - Contact endpoint for device registration and subscriptions
- **`/things`** - Things endpoint for object/item management

### Key Features

1. **HTTP-based notifications** instead of Firebase push notifications
2. **Polling mechanism** for real-time-like notification delivery
3. **Device registration** with CI-Server for notification targeting
4. **Topic subscription/unsubscription** for notification categories
5. **Integration with all CI-Server endpoints** (people, places, content, contact, things)

### Usage Example

```dart
// Create API client with CI-Server URL
final apiClient = ApiClient(
  firestore: FirebaseFirestore.instance,
  ciServerUrl: 'https://your-ci-server.com',
);

// Create notification service
final notificationService = apiClient.createNotificationService();

// Initialize and listen for notifications
await notificationService.initialize();
notificationService.messageStream.listen((notification) {
  // Handle incoming notification
  print('Received: ${notification.title}');
});

// Use CI-Server endpoints
final people = await notificationService.getPeople();
final places = await notificationService.getPlaces();
final things = await notificationService.getThings();
```

### Demo Page

The `NotificationDemoPage` demonstrates:
- Connection status to CI-Server
- Buttons to test each API endpoint (people, places, things)
- Real-time notification display
- Error handling and user feedback

## Changes Made

1. **Removed Firebase messaging dependency** from api_client package
2. **Created HTTP-based NotificationService** that integrates with CI-Server API
3. **Updated ApiClient** to support CI-Server URL configuration
4. **Added demo page** to showcase the integration
5. **Maintained existing Firebase functionality** for other services
6. **Added comprehensive error handling** and logging

This implementation provides a clean separation between Firebase services and the new CI-Server API integration, allowing for a gradual migration while maintaining existing functionality.