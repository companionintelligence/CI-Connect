import 'package:api_client/src/firebase_extensions.dart';
import 'package:api_client/src/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// {@template api_client}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class ApiClient {
  /// Creates an instance of [ApiClient].
  ApiClient({required FirebaseFirestore firestore}) 
      : _firestore = firestore,
        _calendarSyncService = CalendarSyncService(firestore: firestore);

  final FirebaseFirestore _firestore;
  final CalendarSyncService _calendarSyncService;

  /// Generates a new firestore document ID.
  String generateId() => _firestore.generateId();

  /// Gets the calendar sync service for managing calendar synchronization.
  CalendarSyncService get calendarSync => _calendarSyncService;
}
