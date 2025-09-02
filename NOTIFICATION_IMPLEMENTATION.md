# CI-Connect Notification System

This implementation provides notification support for the CI-Connect Flutter application using the CI-Server API exclusively, with all Firebase dependencies removed.

## Architecture

### API Client Package (`packages/api_client`)

The API client package provides a pure CI-Server HTTP endpoint integration:

- **NotificationService**: HTTP-based notification service that integrates with CI-Server API
- **ApiClient**: Simple API client for creating notification service instances with configurable CI-Server URL
- **No Firebase dependencies**: Completely removed Firebase dependencies for a clean CI-Server only implementation

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
6. **Pure CI-Server integration** - no Firebase dependencies

### Usage Example

```dart
// Create API client with CI-Server URL
final apiClient = ApiClient(
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

1. **Completely removed Firebase dependencies** from api_client package
2. **Created pure HTTP-based NotificationService** that integrates with CI-Server API
3. **Refactored ApiClient** to work without Firebase dependencies
4. **Updated package exports** to remove all Firebase references
5. **Added demo page** to showcase the integration
6. **Removed firebase_extensions.dart** as it's no longer needed
7. **Updated documentation** to reflect CI-Server only approach

This implementation provides a clean, Firebase-free integration with the CI-Server API for all notification and data management needs.