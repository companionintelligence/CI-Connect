import 'package:api_client/src/firebase_extensions.dart';
import 'package:api_client/src/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// {@template api_client}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class ApiClient {
  /// Creates an instance of [ApiClient].
  ApiClient({
    required FirebaseFirestore firestore,
    String? ciServerBaseUrl,
  })  : _firestore = firestore,
        _ciServerApiClient = CIServerApiClient(
          baseUrl: ciServerBaseUrl ?? 'https://api.ci-server.com',
        ),
        _calendarSyncService = CalendarSyncService(
          apiClient: CIServerApiClient(
            baseUrl: ciServerBaseUrl ?? 'https://api.ci-server.com',
          ),
        );

  final FirebaseFirestore _firestore;
  final CIServerApiClient _ciServerApiClient;
  final CalendarSyncService _calendarSyncService;

  /// Generates a new firestore document ID.
  String generateId() => _firestore.generateId();

  /// Gets the calendar sync service for managing calendar synchronization.
  CalendarSyncService get calendarSync => _calendarSyncService;

  /// Gets the CI-Server API client for direct API access.
  CIServerApiClient get ciServerApi => _ciServerApiClient;

  /// Dispose of resources.
  void dispose() {
    _ciServerApiClient.dispose();
  }
}
