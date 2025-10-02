import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:api_client/api_client.dart' as api_client;
import 'package:companion_connect/app/bloc/app_bloc.dart';

import 'location_event.dart';
import 'location_state.dart';
import '../models/location.dart' as location_models;

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final api_client.ApiClient _apiClient;
  final AppBloc _appBloc;

  StreamSubscription<Position>? _locationSubscription;
  Timer? _uploadTimer;
  List<location_models.Location> _pendingLocations = [];

  LocationBloc({
    required api_client.ApiClient apiClient,
    required AppBloc appBloc,
  }) : _apiClient = apiClient,
       _appBloc = appBloc,
       super(const LocationInitial()) {
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<LoadLocations>(_onLoadLocations);
    on<UploadLocations>(_onUploadLocations);
    on<RetryUpload>(_onRetryUpload);
    on<StartBackgroundTracking>(_onStartBackgroundTracking);
    on<StopBackgroundTracking>(_onStopBackgroundTracking);
    on<LocationUpdateReceived>(_onLocationUpdateReceived);
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _uploadTimer?.cancel();
    return super.close();
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<LocationState> emit,
  ) async {
    try {
      print('LocationBloc: Requesting location permission...');

      // Check current permission status first
      final status = await Permission.location.status;

      if (status.isGranted) {
        // Check if we have background location permission
        final backgroundStatus = await Permission.locationAlways.status;
        if (backgroundStatus.isGranted) {
          print(
            'LocationBloc: Background permission already granted, starting background tracking...',
          );
          add(const StartBackgroundTracking());
          return;
        } else {
          print('LocationBloc: Need to request background location permission');
          // Request background location permission
          final backgroundPermission = await Permission.locationAlways
              .request();
          if (backgroundPermission.isGranted) {
            print(
              'LocationBloc: Background permission granted, starting tracking...',
            );
            add(const StartBackgroundTracking());
            return;
          } else {
            print('LocationBloc: Background permission denied');
            emit(const LocationPermissionDenied());
            return;
          }
        }
      }

      if (status.isPermanentlyDenied) {
        print('LocationBloc: Permission permanently denied');
        emit(const LocationPermissionDenied());
        return;
      }

      // Request basic location permission first
      final permission = await Permission.location.request();

      if (permission.isGranted) {
        print(
          'LocationBloc: Basic permission granted, requesting background permission...',
        );
        // Now request background location permission
        final backgroundPermission = await Permission.locationAlways.request();
        if (backgroundPermission.isGranted) {
          print(
            'LocationBloc: Background permission granted, starting tracking...',
          );
          add(const StartBackgroundTracking());
        } else {
          print('LocationBloc: Background permission denied');
          emit(const LocationPermissionDenied());
        }
      } else if (permission.isPermanentlyDenied) {
        print('LocationBloc: Permission permanently denied');
        emit(const LocationPermissionDenied());
      } else {
        print('LocationBloc: Permission denied');
        emit(const LocationPermissionDenied());
      }
    } catch (e) {
      print('LocationBloc: Error requesting permission: $e');
      emit(LocationError(message: 'Failed to request location permission: $e'));
    }
  }

  Future<void> _onLoadLocations(
    LoadLocations event,
    Emitter<LocationState> emit,
  ) async {
    try {
      print('LocationBloc: Loading current location...');
      emit(const LocationLoading());

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
        'LocationBloc: Got current location: ${position.latitude}, ${position.longitude}',
      );

      // Create a single location entry
      final location = location_models.Location(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Current Location',
        description: 'Location captured at ${DateTime.now()}',
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp,
        provider: 'geolocator',
        isFromMockProvider: false, // Geolocator doesn't expose isMock directly
        source: 'mobile_app',
      );

      final locations = [location];
      print('LocationBloc: Loaded ${locations.length} locations');

      // Calculate batches (50 locations per batch)
      final totalBatches = (locations.length / 50).ceil();

      emit(
        LocationLoaded(
          locations: locations,
          totalLocations: locations.length,
          uploadedBatches: 0,
          totalBatches: totalBatches,
          isUploading: false,
        ),
      );
    } catch (e) {
      print('LocationBloc: Error loading locations: $e');
      emit(LocationError(message: 'Failed to load locations: $e'));
    }
  }

  Future<void> _onStartBackgroundTracking(
    StartBackgroundTracking event,
    Emitter<LocationState> emit,
  ) async {
    try {
      print('LocationBloc: Starting background location tracking...');

      // Start location stream
      _locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10, // Update every 10 meters
            ),
          ).listen(
            (Position position) {
              print(
                'LocationBloc: Received location update: ${position.latitude}, ${position.longitude}',
              );

              final location = location_models.Location(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: 'Background Location',
                description: 'Location captured at ${DateTime.now()}',
                latitude: position.latitude,
                longitude: position.longitude,
                accuracy: position.accuracy,
                altitude: position.altitude,
                speed: position.speed,
                heading: position.heading,
                timestamp: position.timestamp,
                provider: 'geolocator',
                isFromMockProvider:
                    false, // Geolocator doesn't expose isMock directly
                source: 'background_tracking',
              );

              add(LocationUpdateReceived(location));
            },
            onError: (Object error) {
              print('LocationBloc: Location stream error: $error');
              emit(LocationError(message: 'Location tracking error: $error'));
            },
          );

      // Start upload timer (every minute)
      _uploadTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        print(
          'LocationBloc: Timer triggered - uploading pending locations (${_pendingLocations.length} pending)',
        );
        add(const UploadLocations());
      });

      // Initialize tracking state
      emit(
        LocationTracking(
          locations: _pendingLocations,
          totalLocations: _pendingLocations.length,
          uploadedBatches: 0,
          totalBatches: 0,
          isUploading: false,
          isTracking: true,
        ),
      );

      print('LocationBloc: Background tracking started successfully');
    } catch (e) {
      print('LocationBloc: Error starting background tracking: $e');
      emit(LocationError(message: 'Failed to start background tracking: $e'));
    }
  }

  Future<void> _onStopBackgroundTracking(
    StopBackgroundTracking event,
    Emitter<LocationState> emit,
  ) async {
    print('LocationBloc: Stopping background location tracking...');

    _locationSubscription?.cancel();
    _uploadTimer?.cancel();

    emit(
      LocationTracking(
        locations: _pendingLocations,
        totalLocations: _pendingLocations.length,
        uploadedBatches: 0,
        totalBatches: 0,
        isUploading: false,
        isTracking: false,
      ),
    );
  }

  Future<void> _onLocationUpdateReceived(
    LocationUpdateReceived event,
    Emitter<LocationState> emit,
  ) async {
    print('LocationBloc: Adding new location to pending list');

    _pendingLocations.add(event.location);
    print('LocationBloc: Total pending locations: ${_pendingLocations.length}');

    final currentState = state;
    if (currentState is LocationTracking) {
      // Create new list with the new location added
      final updatedLocations = List<location_models.Location>.from(
        currentState.locations,
      )..add(event.location);

      emit(
        LocationTracking(
          locations: updatedLocations,
          totalLocations: updatedLocations.length,
          uploadedBatches: currentState.uploadedBatches,
          totalBatches: currentState.totalBatches,
          isUploading: currentState.isUploading,
          isTracking: currentState.isTracking,
        ),
      );
    }
  }

  Future<void> _onUploadLocations(
    UploadLocations event,
    Emitter<LocationState> emit,
  ) async {
    try {
      // Get current state to access pending locations
      final currentState = state;
      if (currentState is! LocationTracking) {
        print('LocationBloc: Not in tracking state, cannot upload');
        return;
      }

      if (currentState.locations.isEmpty) {
        print('LocationBloc: No pending locations to upload');
        return;
      }

      print(
        'LocationBloc: Starting locations upload with ${currentState.locations.length} pending locations...',
      );

      // Get access token from app bloc
      final appState = _appBloc.state;
      if (appState is! AppAuthenticated) {
        emit(const LocationError(message: 'Not authenticated'));
        return;
      }

      final accessToken = appState.session.accessToken;

      // Create batches from current state locations
      final batches = _createBatches(currentState.locations, 50);
      print('LocationBloc: Created ${batches.length} batches');

      int uploadedBatches = 0;

      for (int i = 0; i < batches.length; i++) {
        print(
          'LocationBloc: Uploading batch ${i + 1}/${batches.length} with ${batches[i].length} locations',
        );
        await _uploadBatch(batches[i], accessToken);
        uploadedBatches++;

        // Update progress
        final progressState = state;
        if (progressState is LocationTracking) {
          emit(
            LocationTracking(
              locations: progressState.locations,
              totalLocations: progressState.locations.length,
              uploadedBatches: uploadedBatches,
              totalBatches: batches.length,
              isUploading: true,
              isTracking: progressState.isTracking,
            ),
          );
        }
      }

      // Clear uploaded locations from both private field and state
      _pendingLocations.clear();
      print(
        'LocationBloc: Cleared ${_pendingLocations.length} pending locations after upload',
      );

      print('LocationBloc: Successfully uploaded all batches');
      final finalState = state;
      if (finalState is LocationTracking) {
        emit(
          LocationTracking(
            locations: const [], // Clear all locations after successful upload
            totalLocations: 0,
            uploadedBatches: uploadedBatches,
            totalBatches: batches.length,
            isUploading: false,
            isTracking: finalState.isTracking,
          ),
        );
      }
    } catch (e) {
      print('LocationBloc: Error uploading locations: $e');
      emit(LocationError(message: 'Failed to upload locations: $e'));
    }
  }

  Future<void> _onRetryUpload(
    RetryUpload event,
    Emitter<LocationState> emit,
  ) async {
    add(const UploadLocations());
  }

  List<List<location_models.Location>> _createBatches(
    List<location_models.Location> locations,
    int batchSize,
  ) {
    final batches = <List<location_models.Location>>[];
    for (int i = 0; i < locations.length; i += batchSize) {
      final end = (i + batchSize < locations.length)
          ? i + batchSize
          : locations.length;
      batches.add(locations.sublist(i, end));
    }
    return batches;
  }

  Future<void> _uploadBatch(
    List<location_models.Location> batch,
    String accessToken,
  ) async {
    final dio = Dio();

    // Convert locations to JSON
    final locationsJson = batch.map((location) => location.toJson()).toList();

    print(
      'LocationBloc: Uploading batch with ${locationsJson.length} locations',
    );

    // Validate JSON structure
    try {
      final jsonString = jsonEncode(locationsJson);
      print(
        'LocationBloc: JSON validation successful, length: ${jsonString.length}',
      );
    } catch (e) {
      print('LocationBloc: JSON validation failed: $e');
      throw Exception('Invalid JSON structure: $e');
    }

    // Try different request formats to see what the server expects
    dynamic requestData;
    Response<dynamic> response;

    // Format 1: Content field (based on database schema)
    requestData = {
      'content': locationsJson,
    };

    print('LocationBloc: Trying format 1 - Content field');

    try {
      response = await dio.post(
        '${_apiClient.ciServerBaseUrl}/etl/locations',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('LocationBloc: Format 1 failed: $e');

      // Format 2: Direct array
      requestData = locationsJson;
      print('LocationBloc: Trying format 2 - Direct array');

      try {
        response = await dio.post(
          '${_apiClient.ciServerBaseUrl}/etl/locations',
          data: requestData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
      } catch (e2) {
        print('LocationBloc: Format 2 failed: $e2');

        // Format 3: Locations field
        requestData = {
          'locations': locationsJson,
        };
        print('LocationBloc: Trying format 3 - Locations field');

        response = await dio.post(
          '${_apiClient.ciServerBaseUrl}/etl/locations',
          data: requestData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
      }
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('LocationBloc: Upload failed with status: ${response.statusCode}');
      print('LocationBloc: Response data: ${response.data}');
      throw Exception(
        'Upload failed with status: ${response.statusCode} - ${response.data}',
      );
    }

    print('LocationBloc: Successfully uploaded batch');
  }
}
