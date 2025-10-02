import 'package:api_client/api_client.dart';

/// Dependency injection providers for the app
class AppProviders {
  /// Creates an [AppProviders] instance
  const AppProviders({
    required this.apiUrl,
  });

  final String apiUrl;

  /// Creates the authentication service
  AuthService createAuthService() {
    return AuthService(baseUrl: apiUrl);
  }

  /// Creates the authentication repository
  AuthRepository createAuthRepository() {
    return ApiAuthRepository(
      authService: createAuthService(),
    );
  }

  /// Creates the API client
  ApiClient createApiClient() {
    return ApiClient(ciServerBaseUrl: apiUrl);
  }

  /// Creates the connectivity service
  ConnectivityService createConnectivityService() {
    return ConnectivityService(
      apiClient: createApiClient(),
    );
  }

  /// Creates the enhanced sync client
  EnhancedSyncClient createEnhancedSyncClient() {
    return EnhancedSyncClient(baseUrl: apiUrl);
  }
}
