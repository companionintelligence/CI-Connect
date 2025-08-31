import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles Firebase Cloud Messaging (FCM) notifications.
class NotificationService {
  NotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  
  /// Stream of FCM tokens
  final _tokenController = StreamController<String>.broadcast();
  Stream<String> get tokenStream => _tokenController.stream;
  
  /// Stream of notification messages when app is in foreground
  final _messageController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messageStream => _messageController.stream;

  /// Current FCM token
  String? _currentToken;
  String? get currentToken => _currentToken;

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Request notification permissions
      await requestPermission();
      
      // Get initial token
      await _refreshToken();
      
      // Listen for token refresh
      _messaging.onTokenRefresh.listen((token) {
        _currentToken = token;
        _tokenController.add(token);
        log('FCM token refreshed: $token');
      });
      
      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Received foreground message: ${message.messageId}');
        _messageController.add(message);
      });
      
      // Handle messages when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('App opened from background message: ${message.messageId}');
        _messageController.add(message);
      });
      
      log('NotificationService initialized successfully');
    } catch (e, stackTrace) {
      log('Failed to initialize NotificationService: $e', 
          stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Request notification permissions from the user
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    log('Notification permission status: ${settings.authorizationStatus}');
    return settings;
  }

  /// Get the current FCM token
  Future<String?> getToken() async {
    if (_currentToken != null) return _currentToken;
    return _refreshToken();
  }

  /// Refresh and get a new FCM token
  Future<String?> _refreshToken() async {
    try {
      final token = await _messaging.getToken();
      _currentToken = token;
      if (token != null) {
        _tokenController.add(token);
        log('FCM token: $token');
      }
      return token;
    } catch (e) {
      log('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// Handle notification when app is launched from a terminated state
  Future<RemoteMessage?> getInitialMessage() async {
    return _messaging.getInitialMessage();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Dispose of resources
  void dispose() {
    _tokenController.close();
    _messageController.close();
  }
}

/// Global function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Received background message: ${message.messageId}');
  // Handle the background message here
  // This function must be a top-level function
}