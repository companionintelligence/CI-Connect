import 'package:equatable/equatable.dart';
import '../models/location.dart' as location_models;

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class RequestLocationPermission extends LocationEvent {
  const RequestLocationPermission();
}

class LoadLocations extends LocationEvent {
  const LoadLocations();
}

class UploadLocations extends LocationEvent {
  const UploadLocations();
}

class RetryUpload extends LocationEvent {
  const RetryUpload();
}

class StartBackgroundTracking extends LocationEvent {
  const StartBackgroundTracking();
}

class StopBackgroundTracking extends LocationEvent {
  const StopBackgroundTracking();
}

class LocationUpdateReceived extends LocationEvent {
  final location_models.Location location;

  const LocationUpdateReceived(this.location);

  @override
  List<Object?> get props => [location];
}
