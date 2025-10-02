import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Notification data structure from CI-Server
class NotificationData {
  const NotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.data = const {},
    this.timestamp,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? timestamp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

/// Handles notifications using CI-Server API endpoints.
class NotificationService {
  NotificationService({
    required String baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;

  /// Stream of notification messages
  final _messageController = StreamController<NotificationData>.broadcast();
  Stream<NotificationData> get messageStream => _messageController.stream;

  /// Device token for push notifications
  String? _deviceToken;
  String? get deviceToken => _deviceToken;

  Timer? _pollingTimer;

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Generate a unique device identifier for this session
      _deviceToken = DateTime.now().millisecondsSinceEpoch.toString();

      // Register device with the server
      await _registerDevice();

      // Start polling for notifications (in a real implementation,
      // this might use WebSockets or Server-Sent Events)
      _startPolling();

      log('NotificationService initialized successfully');
    } catch (e, stackTrace) {
      log(
        'Failed to initialize NotificationService: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Register this device with the CI-Server for notifications
  Future<void> _registerDevice() async {
    try {
      await _dio.post(
        '/contact',
        data: {
          'device_token': _deviceToken,
          'platform': defaultTargetPlatform.name,
          'registered_at': DateTime.now().toIso8601String(),
        },
      );
      log('Device registered with CI-Server');
    } catch (e) {
      log('Failed to register device: $e');
      // Don't rethrow here - allow service to continue even if registration fails
    }
  }

  /// Start polling for new notifications
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        await _pollForNotifications();
      } catch (e) {
        log('Error polling for notifications: $e');
      }
    });
  }

  /// Poll the server for new notifications
  Future<void> _pollForNotifications() async {
    try {
      final response = await _dio.get(
        '/content/notifications',
        queryParameters: {
          'device_token': _deviceToken,
          'since': DateTime.now()
              .subtract(const Duration(minutes: 1))
              .toIso8601String(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final notifications =
            (response.data['notifications'] as List<dynamic>?) ?? [];

        for (final notificationJson in notifications) {
          final notification = NotificationData.fromJson(
            notificationJson as Map<String, dynamic>,
          );
          _messageController.add(notification);
          log('Received notification: ${notification.title}');
        }
      }
    } catch (e) {
      // Log but don't throw - polling should be resilient
      log('Failed to poll for notifications: $e');
    }
  }

  /// Send a notification (for testing or admin purposes)
  Future<void> sendNotification(NotificationData notification) async {
    try {
      await _dio.post('/content/notifications', data: notification.toJson());
      log('Notification sent: ${notification.title}');
    } catch (e) {
      log('Failed to send notification: $e');
      rethrow;
    }
  }

  /// Get people from CI-Server (example of using the people endpoint)
  Future<List<Map<String, dynamic>>> getPeople() async {
    try {
      final response = await _dio.get('/people');
      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(
          (response.data['people'] as List<dynamic>?) ?? [],
        );
      }
      return [];
    } catch (e) {
      log('Failed to get people: $e');
      return [];
    }
  }

  /// Get places from CI-Server (example of using the places endpoint)
  Future<List<Map<String, dynamic>>> getPlaces() async {
    try {
      final response = await _dio.get('/places');
      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(
          (response.data['places'] as List<dynamic>?) ?? [],
        );
      }
      return [];
    } catch (e) {
      log('Failed to get places: $e');
      return [];
    }
  }

  /// Get things from CI-Server (example of using the things endpoint)
  Future<List<Map<String, dynamic>>> getThings() async {
    try {
      final response = await _dio.get('/things');
      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(
          (response.data['things'] as List<dynamic>?) ?? [],
        );
      }
      return [];
    } catch (e) {
      log('Failed to get things: $e');
      return [];
    }
  }

  /// Subscribe to notifications for a specific topic/category
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _dio.post(
        '/contact/subscribe',
        data: {
          'device_token': _deviceToken,
          'topic': topic,
        },
      );
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from notifications for a specific topic/category
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _dio.delete(
        '/contact/subscribe',
        data: {
          'device_token': _deviceToken,
          'topic': topic,
        },
      );
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// Check if notifications are enabled (always true for HTTP-based notifications)
  Future<bool> areNotificationsEnabled() async {
    return true;
  }

  /// Dispose of resources
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.close();
  }
}
