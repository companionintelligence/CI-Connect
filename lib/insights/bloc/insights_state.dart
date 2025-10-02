import 'package:companion_connect/insights/models/insight.dart';

/// Insights state
abstract class InsightsState {
  const InsightsState();
}

/// Initial insights state
class InsightsInitial extends InsightsState {
  const InsightsInitial();
}

/// Insights loading state
class InsightsLoading extends InsightsState {
  const InsightsLoading();
}

/// Insights loaded state
class InsightsLoaded extends InsightsState {
  const InsightsLoaded({required this.insights});
  final List<Insight> insights;
}

/// Insights error state
class InsightsError extends InsightsState {
  const InsightsError({required this.message});
  final String message;
}
