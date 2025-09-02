/// {@template health_data}
/// Health data model for contacts sync
/// {@endtemplate}
class HealthData {
  /// {@macro health_data}
  const HealthData({
    required this.id,
    required this.contactId,
    required this.dataType,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.notes,
    this.metadata,
  });

  /// Creates a [HealthData] from a JSON map.
  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      id: json['id'] as String,
      contactId: json['contactId'] as String,
      dataType: json['dataType'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// The unique identifier for this health data entry
  final String id;

  /// The contact ID this health data belongs to
  final String contactId;

  /// Type of health data (e.g., 'heart_rate', 'blood_pressure', 'weight')
  final String dataType;

  /// The health data value
  final String value;

  /// Unit of measurement for the value
  final String unit;

  /// Timestamp when the data was recorded
  final DateTime timestamp;

  /// Optional notes about this health data
  final String? notes;

  /// Additional metadata as key-value pairs
  final Map<String, dynamic>? metadata;

  /// Converts this [HealthData] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'dataType': dataType,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  /// Creates a copy of this [HealthData] with the given fields replaced.
  HealthData copyWith({
    String? id,
    String? contactId,
    String? dataType,
    String? value,
    String? unit,
    DateTime? timestamp,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return HealthData(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      dataType: dataType ?? this.dataType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          contactId == other.contactId &&
          dataType == other.dataType &&
          value == other.value &&
          unit == other.unit &&
          timestamp == other.timestamp &&
          notes == other.notes &&
          metadata == other.metadata;

  @override
  int get hashCode =>
      id.hashCode ^
      contactId.hashCode ^
      dataType.hashCode ^
      value.hashCode ^
      unit.hashCode ^
      timestamp.hashCode ^
      notes.hashCode ^
      metadata.hashCode;

  @override
  String toString() {
    return 'HealthData{id: $id, contactId: $contactId, dataType: $dataType, '
        'value: $value, unit: $unit, timestamp: $timestamp, notes: $notes, '
        'metadata: $metadata}';
  }
}