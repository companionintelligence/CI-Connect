import 'package:equatable/equatable.dart';
import '../models/location.dart' as location_models;

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  final List<location_models.Location> locations;
  final int totalLocations;
  final int uploadedBatches;
  final int totalBatches;
  final bool isUploading;

  const LocationLoaded({
    required this.locations,
    required this.totalLocations,
    required this.uploadedBatches,
    required this.totalBatches,
    required this.isUploading,
  });

  @override
  List<Object?> get props => [
    locations,
    totalLocations,
    uploadedBatches,
    totalBatches,
    isUploading,
  ];
}

class LocationPermissionDenied extends LocationState {
  const LocationPermissionDenied();
}

class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocationTracking extends LocationState {
  final List<location_models.Location> locations;
  final int totalLocations;
  final int uploadedBatches;
  final int totalBatches;
  final bool isUploading;
  final bool isTracking;

  const LocationTracking({
    required this.locations,
    required this.totalLocations,
    required this.uploadedBatches,
    required this.totalBatches,
    required this.isUploading,
    required this.isTracking,
  });

  @override
  List<Object?> get props => [
    locations,
    totalLocations,
    uploadedBatches,
    totalBatches,
    isUploading,
    isTracking,
  ];
}
