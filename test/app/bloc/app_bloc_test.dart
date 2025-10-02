import 'package:api_client/api_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:companion_connect/app/bloc/app_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBloc', () {
    late AppBloc appBloc;
    late AuthRepository authRepository;
    late ConnectivityService connectivityService;

    setUp(() {
      const apiUrl = String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://192.168.1.2:3030',
      );

      authRepository = ApiAuthRepository(
        authService: AuthService(
          baseUrl: apiUrl,
        ),
      );
      connectivityService = ConnectivityService(
        apiClient: ApiClient(
          ciServerBaseUrl: apiUrl,
        ),
      );
      appBloc = AppBloc(
        authRepository: authRepository,
        connectivityService: connectivityService,
        apiUrl: apiUrl,
      );
    });

    tearDown(() {
      appBloc.close();
    });

    test('initial state is AppInitial', () {
      expect(appBloc.state, equals(const AppInitial()));
    });

    blocTest<AppBloc, AppState>(
      'emits [AppLoading, AppUnauthenticated] when AppStarted is added and no session exists',
      build: () => appBloc,
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [
        const AppLoading(),
        const AppUnauthenticated(),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppLoading, AppError] when login fails with invalid credentials',
      build: () => appBloc,
      act: (bloc) => bloc.add(
        const AppLoginRequested(
          username: 'invalid',
          password: 'invalid',
        ),
      ),
      expect: () => [
        const AppLoading(),
        isA<AppError>(),
      ],
    );

    blocTest<AppBloc, AppState>(
      'emits [AppUnauthenticated] when logout is requested',
      build: () => appBloc,
      act: (bloc) => bloc.add(const AppLogoutRequested()),
      expect: () => [
        const AppUnauthenticated(),
      ],
    );
  });
}
