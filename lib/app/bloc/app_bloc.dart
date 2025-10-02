import 'dart:async';
import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App state for authentication
abstract class AppState {
  const AppState();
}

/// Initial app state
class AppInitial extends AppState {
  const AppInitial();
}

/// App is loading
class AppLoading extends AppState {
  const AppLoading();
}

/// App is authenticated
class AppAuthenticated extends AppState {
  const AppAuthenticated({
    required this.session,
  });

  final AuthSession session;
}

/// App is not authenticated
class AppUnauthenticated extends AppState {
  const AppUnauthenticated();
}

/// App authentication error
class AppError extends AppState {
  const AppError({
    required this.message,
  });

  final String message;
}

/// App events
abstract class AppEvent {
  const AppEvent();
}

/// Check authentication status on app start
class AppStarted extends AppEvent {
  const AppStarted();
}

/// User login attempt
class AppLoginRequested extends AppEvent {
  const AppLoginRequested({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}

/// User logout
class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}

/// Clear error state and return to initial
class AppClearError extends AppEvent {
  const AppClearError();
}

/// Manually refresh access token
class AppRefreshToken extends AppEvent {
  const AppRefreshToken();
}

/// App bloc for managing authentication state
class AppBloc extends Bloc<AppEvent, AppState> {
  /// Creates an [AppBloc] instance.
  AppBloc({
    required this.authRepository,
    required this.connectivityService,
    required this.apiUrl,
  }) : super(const AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppLoginRequested>(_onAppLoginRequested);
    on<AppLogoutRequested>(_onAppLogoutRequested);
    on<AppClearError>(_onAppClearError);
    on<AppRefreshToken>(_onAppRefreshToken);

    // Start token refresh timer immediately
    _startTokenRefreshTimer();

    print('🚀 AppBloc created - token refresh timer started');
  }

  final AuthRepository authRepository;
  final ConnectivityService connectivityService;
  final String apiUrl;
  Timer? _tokenRefreshTimer;
  AuthSession? _currentSession;

  /// Handles app start event
  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    emit(const AppLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('session_token');

      if (sessionToken != null) {
        // Get stored session data first (no network call)
        final sessionData = prefs.getString('session_data');
        if (sessionData != null) {
          try {
            final sessionJson = jsonDecode(sessionData) as Map<String, dynamic>;
            _currentSession = AuthSession.fromJson(sessionJson);

            // Immediately refresh the access token on app start
            await _refreshAccessTokenOnStart(emit);
            return;
          } catch (e) {
            // Invalid session data, clear it
            await prefs.remove('session_token');
            await prefs.remove('session_data');
          }
        }
      }

      // No valid session found - go to login page
      emit(const AppUnauthenticated());
    } on Exception catch (e) {
      emit(AppError(message: 'Failed to check authentication status: $e'));
    }
  }

  /// Handles login request
  Future<void> _onAppLoginRequested(
    AppLoginRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(const AppLoading());

    try {
      final credentials = AuthCredentials(
        username: event.username,
        password: event.password,
      );

      final session = await authRepository.authenticate(credentials);
      _currentSession = session;

      // Store session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_token', session.sessionToken);
      await prefs.setString('session_data', jsonEncode(session.toJson()));

      print('✅ Login successful - access token is fresh');
      emit(AppAuthenticated(session: session));
    } on AuthException catch (e) {
      // Clear any stored session data on auth failure
      _clearStoredSession();
      emit(AppError(message: e.message));
    } on Exception catch (e) {
      // Clear any stored session data on auth failure
      _clearStoredSession();
      emit(AppError(message: 'Login failed: $e'));
    }
  }

  /// Handles logout request
  Future<void> _onAppLogoutRequested(
    AppLogoutRequested event,
    Emitter<AppState> emit,
  ) async {
    try {
      if (_currentSession != null) {
        await authRepository.logout(_currentSession!.sessionToken);
      }
    } on Exception {
      // Continue with logout even if server call fails
    }

    // Clear stored session data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    await prefs.remove('session_data');

    _currentSession = null;
    _tokenRefreshTimer?.cancel();

    emit(const AppUnauthenticated());
  }

  /// Handles clear error request
  Future<void> _onAppClearError(
    AppClearError event,
    Emitter<AppState> emit,
  ) async {
    // Clear any stored session data
    await _clearStoredSession();
    emit(const AppUnauthenticated());
  }

  /// Handles manual token refresh request
  Future<void> _onAppRefreshToken(
    AppRefreshToken event,
    Emitter<AppState> emit,
  ) async {
    if (_currentSession == null) {
      emit(const AppUnauthenticated());
      return;
    }

    try {
      print('🔄 Manual token refresh requested...');
      final newAccessToken = await authRepository.refreshAccessToken(
        _currentSession!.sessionToken,
      );
      _currentSession = _currentSession!.copyWith(accessToken: newAccessToken);

      // Update stored session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'session_data',
        jsonEncode(_currentSession!.toJson()),
      );

      print('✅ Manual token refresh successful');
      emit(AppAuthenticated(session: _currentSession!));
    } on Exception catch (e) {
      print('❌ Manual token refresh failed: $e');
      // If token refresh fails, logout user
      await _clearStoredSession();
      emit(const AppUnauthenticated());
    }
  }

  /// Starts the token refresh timer
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_currentSession != null && state is AppAuthenticated) {
        _refreshAccessToken();
      }
    });
    print('⏰ Token refresh timer started - will refresh every 5 minutes');
  }

  /// Refreshes the access token on app start
  Future<void> _refreshAccessTokenOnStart(Emitter<AppState> emit) async {
    if (_currentSession == null) return;

    try {
      print('🔄 Refreshing access token on app start...');
      final newAccessToken = await authRepository.refreshAccessToken(
        _currentSession!.sessionToken,
      );
      _currentSession = _currentSession!.copyWith(accessToken: newAccessToken);

      // Update stored session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'session_data',
        jsonEncode(_currentSession!.toJson()),
      );

      print('✅ Access token refreshed successfully');
      emit(AppAuthenticated(session: _currentSession!));
    } on Exception catch (e) {
      print('❌ Token refresh failed on app start: $e');
      // If token refresh fails, logout user
      await _clearStoredSession();
      emit(const AppUnauthenticated());
    }
  }

  /// Refreshes the access token
  Future<void> _refreshAccessToken() async {
    if (_currentSession == null) return;

    try {
      print('🔄 Refreshing access token (periodic)...');
      final newAccessToken = await authRepository.refreshAccessToken(
        _currentSession!.sessionToken,
      );
      _currentSession = _currentSession!.copyWith(accessToken: newAccessToken);

      // Update stored session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'session_data',
        jsonEncode(_currentSession!.toJson()),
      );

      print('✅ Access token refreshed successfully (periodic)');
      // Emit updated authenticated state
      add(const AppStarted()); // This will trigger state update
    } on Exception catch (e) {
      print('❌ Token refresh failed (periodic): $e');
      // If token refresh fails, logout user
      add(const AppLogoutRequested());
    }
  }

  /// Clears stored session data
  Future<void> _clearStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_token');
      await prefs.remove('session_data');
      _currentSession = null;
    } catch (e) {
      // Ignore errors when clearing session
    }
  }

  @override
  Future<void> close() {
    _tokenRefreshTimer?.cancel();
    return super.close();
  }
}
