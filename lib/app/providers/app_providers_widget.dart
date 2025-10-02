import 'package:companion_connect/app/bloc/app_bloc.dart';
import 'package:companion_connect/app/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget that provides all app dependencies and blocs
class AppProvidersWidget extends StatelessWidget {
  /// Creates an [AppProvidersWidget] instance.
  const AppProvidersWidget({
    required this.apiUrl,
    required this.child,
    super.key,
  });

  final String apiUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final providers = AppProviders(apiUrl: apiUrl);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>(
          create: (context) => AppBloc(
            authRepository: providers.createAuthRepository(),
            connectivityService: providers.createConnectivityService(),
            apiUrl: apiUrl,
          ),
        ),
      ],
      child: child,
    );
  }
}
