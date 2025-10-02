import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_client/api_client.dart';
import 'package:companion_connect/app/bloc/app_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import '../models/location.dart' as location_models;

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationBloc(
        apiClient: context.read<ApiClient>(),
        appBloc: context.read<AppBloc>(),
      )..add(const RequestLocationPermission()),
      child: const _LocationPageContent(),
    );
  }
}

class _LocationPageContent extends StatelessWidget {
  const _LocationPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Upload'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: BlocSelector<LocationBloc, LocationState, LocationState>(
        selector: (state) => state,
        builder: (context, state) {
          if (state is LocationInitial) {
            return const Center(
              child: Text('Loading...'),
            );
          } else if (state is LocationLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading locations...'),
                ],
              ),
            );
          } else if (state is LocationPermissionDenied) {
            return _buildPermissionDeniedView(context);
          } else if (state is LocationLoaded) {
            return _buildLocationLoadedView(context, state);
          } else if (state is LocationTracking) {
            return _buildLocationTrackingView(context, state);
          } else if (state is LocationError) {
            return _buildErrorView(context, state);
          }
          return const Center(
            child: Text('Unknown state'),
          );
        },
      ),
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Location Permission Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This app needs access to your location to upload location data to your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LocationBloc>().add(
                  const RequestLocationPermission(),
                );
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Grant Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await openAppSettings();
              },
              icon: const Icon(Icons.settings_applications),
              label: const Text('Open App Settings'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTrackingView(
    BuildContext context,
    LocationTracking state,
  ) {
    return BlocSelector<LocationBloc, LocationState, LocationTracking>(
      selector: (state) => state is LocationTracking
          ? state
          : LocationTracking(
              locations: const [],
              totalLocations: 0,
              uploadedBatches: 0,
              totalBatches: 0,
              isUploading: false,
              isTracking: false,
            ),
      builder: (context, trackingState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tracking status card
              Card(
                color: trackingState.isTracking
                    ? Colors.green[50]
                    : Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        trackingState.isTracking
                            ? Icons.location_on
                            : Icons.location_off,
                        color: trackingState.isTracking
                            ? Colors.green
                            : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trackingState.isTracking
                                ? 'Background Tracking Active'
                                : 'Background Tracking Stopped',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: trackingState.isTracking
                                  ? Colors.green[700]
                                  : Colors.grey[700],
                            ),
                          ),
                          Text(
                            trackingState.isTracking
                                ? 'Location data is being collected automatically'
                                : 'Location tracking has been stopped',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildStatCard(
                'Pending Locations',
                '${trackingState.totalLocations}',
                Icons.location_on,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Upload Progress',
                '${trackingState.uploadedBatches}/${trackingState.totalBatches} batches',
                Icons.upload,
                trackingState.isUploading ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 24),

              if (trackingState.isUploading)
                const LinearProgressIndicator()
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: trackingState.isTracking
                            ? () {
                                context.read<LocationBloc>().add(
                                  const StopBackgroundTracking(),
                                );
                              }
                            : () {
                                context.read<LocationBloc>().add(
                                  const StartBackgroundTracking(),
                                );
                              },
                        icon: Icon(
                          trackingState.isTracking
                              ? Icons.stop
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          trackingState.isTracking
                              ? 'Stop Tracking'
                              : 'Start Tracking',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: trackingState.isTracking
                              ? Colors.red[600]
                              : Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<LocationBloc>().add(
                            const UploadLocations(),
                          );
                        },
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              const Text(
                'Recent Locations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trackingState.locations.length > 10
                    ? 10
                    : trackingState.locations.length,
                itemBuilder: (context, index) {
                  final location = trackingState.locations[index];
                  return _buildLocationTile(location);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationLoadedView(BuildContext context, LocationLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            'Total Locations',
            '${state.totalLocations}',
            Icons.location_on,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Upload Progress',
            '${state.uploadedBatches}/${state.totalBatches} batches',
            Icons.upload,
            state.isUploading ? Colors.orange : Colors.green,
          ),
          const SizedBox(height: 24),
          if (state.isUploading)
            const LinearProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<LocationBloc>().add(const UploadLocations());
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload All Locations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Location Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.locations.length,
            itemBuilder: (context, index) {
              final location = state.locations[index];
              return _buildLocationTile(location);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile(location_models.Location location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.blue),
        title: Text(
          location.name ?? 'Unknown Location',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (location.latitude != null && location.longitude != null)
              Text(
                'Lat: ${location.latitude!.toStringAsFixed(6)}, Lng: ${location.longitude!.toStringAsFixed(6)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            if (location.address != null && location.address!.isNotEmpty)
              Text(
                location.address!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            if (location.timestamp != null)
              Text(
                'Captured: ${location.timestamp!.toString()}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, LocationError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LocationBloc>().add(const RetryUpload());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
