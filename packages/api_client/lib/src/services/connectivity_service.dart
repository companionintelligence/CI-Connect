import 'dart:developer';
import 'package:api_client/api_client.dart';

/// Service for checking API connectivity
class ConnectivityService {
  /// Creates a [ConnectivityService] instance.
  ConnectivityService({
    required this.apiClient,
  });

  final ApiClient apiClient;

  /// Checks if the API server is reachable
  Future<bool> isConnected() async {
    try {
      // Test connectivity by trying to get people with a small limit
      await apiClient.getPeople(limit: 1);
      log('API connectivity: Connected');
      return true;
    } catch (e) {
      log('API connectivity: Not connected - $e');
      return false;
    }
  }

  /// Gets basic server status information
  Future<Map<String, dynamic>?> getServerStatus() async {
    try {
      final people = await apiClient.getPeople(limit: 1);
      return {
        'connected': true,
        'people_count': people.length,
        'base_url': apiClient.ciServerBaseUrl,
      };
    } catch (e) {
      log('Failed to get server status: $e');
      return {
        'connected': false,
        'error': e.toString(),
        'base_url': apiClient.ciServerBaseUrl,
      };
    }
  }
}
