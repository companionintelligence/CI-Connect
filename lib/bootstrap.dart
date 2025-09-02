import 'dart:async';
import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Initialize API Client with CI Server connectivity
  try {
    final apiClient = ApiClient();
    
    // Test CI Server connectivity during app startup
    final isConnected = await apiClient.isConnectedToCiServer();
    log('CI Server connectivity: ${isConnected ? "Connected" : "Not connected"}');
    
    if (isConnected) {
      final status = await apiClient.getCiServerStatus();
      if (status != null) {
        log('CI Server status: $status');
      }
    }
  } catch (e) {
    log('Failed to initialize CI Server connectivity: $e');
  }

  runApp(await builder());
}
