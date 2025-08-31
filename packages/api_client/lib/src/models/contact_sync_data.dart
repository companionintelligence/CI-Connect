import 'package:json_annotation/json_annotation.dart';
import 'health_data.dart';

part 'contact_sync_data.g.dart';

/// {@template contact_sync_data}
/// Contact data with associated health information for syncing
/// {@endtemplate}
@JsonSerializable()
class ContactSyncData {
  /// {@macro contact_sync_data}
  const ContactSyncData({
    required this.contactId,
    required this.studioId,
    required this.lastSyncTime,
    required this.healthData,
    this.syncStatus = ContactSyncStatus.pending,
    this.errorMessage,
    this.retryCount = 0,
  });

  /// Creates a [ContactSyncData] from a JSON map.
  factory ContactSyncData.fromJson(Map<String, dynamic> json) =>
      _$ContactSyncDataFromJson(json);

  /// The contact ID being synced
  final String contactId;

  /// The studio ID this contact belongs to
  final String studioId;

  /// Last time this contact's data was synced
  final DateTime lastSyncTime;

  /// List of health data entries for this contact
  final List<HealthData> healthData;

  /// Current sync status
  final ContactSyncStatus syncStatus;

  /// Error message if sync failed
  final String? errorMessage;

  /// Number of retry attempts
  final int retryCount;

  /// Converts this [ContactSyncData] to a JSON map.
  Map<String, dynamic> toJson() => _$ContactSyncDataToJson(this);

  /// Creates a copy of this [ContactSyncData] with the given fields replaced.
  ContactSyncData copyWith({
    String? contactId,
    String? studioId,
    DateTime? lastSyncTime,
    List<HealthData>? healthData,
    ContactSyncStatus? syncStatus,
    String? errorMessage,
    int? retryCount,
  }) {
    return ContactSyncData(
      contactId: contactId ?? this.contactId,
      studioId: studioId ?? this.studioId,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      healthData: healthData ?? this.healthData,
      syncStatus: syncStatus ?? this.syncStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactSyncData &&
          runtimeType == other.runtimeType &&
          contactId == other.contactId &&
          studioId == other.studioId &&
          lastSyncTime == other.lastSyncTime &&
          healthData == other.healthData &&
          syncStatus == other.syncStatus &&
          errorMessage == other.errorMessage &&
          retryCount == other.retryCount;

  @override
  int get hashCode =>
      contactId.hashCode ^
      studioId.hashCode ^
      lastSyncTime.hashCode ^
      healthData.hashCode ^
      syncStatus.hashCode ^
      errorMessage.hashCode ^
      retryCount.hashCode;

  @override
  String toString() {
    return 'ContactSyncData{contactId: $contactId, studioId: $studioId, '
        'lastSyncTime: $lastSyncTime, healthData: $healthData, '
        'syncStatus: $syncStatus, errorMessage: $errorMessage, '
        'retryCount: $retryCount}';
  }
}

/// Status of contact sync operation
enum ContactSyncStatus {
  /// Sync is pending
  @JsonValue('pending')
  pending,

  /// Sync is in progress
  @JsonValue('syncing')
  syncing,

  /// Sync completed successfully
  @JsonValue('completed')
  completed,

  /// Sync failed
  @JsonValue('failed')
  failed,

  /// Sync was cancelled
  @JsonValue('cancelled')
  cancelled,
}