/// Insights events
abstract class InsightsEvent {
  const InsightsEvent();
}

/// Load insights event
class LoadInsights extends InsightsEvent {
  const LoadInsights({required this.accessToken});
  final String accessToken;
}
