/// {@template calendar}
/// A calendar entity that represents a synced calendar from external sources.
/// {@endtemplate}
class Calendar {
  /// {@macro calendar}
  const Calendar({
    required this.id,
    required this.name,
    required this.isEnabled,
    required this.source,
    required this.createdAt,
    this.description,
    this.color,
    this.timeZone,
    this.lastSyncedAt,
    this.updatedAt,
  });

  /// Creates a [Calendar] from a JSON map.
  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      timeZone: json['timeZone'] as String?,
      isEnabled: json['isEnabled'] as bool,
      source: json['source'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// The unique identifier for this calendar.
  final String id;

  /// The display name of the calendar.
  final String name;

  /// Optional description of the calendar.
  final String? description;

  /// The color associated with this calendar (hex color code).
  final String? color;

  /// The timezone of the calendar (e.g., "America/New_York").
  final String? timeZone;

  /// Whether this calendar is enabled for synchronization.
  final bool isEnabled;

  /// The source of this calendar (e.g., "google", "outlook", "apple").
  final String source;

  /// When this calendar was created.
  final DateTime createdAt;

  /// When this calendar was last synced with its external source.
  final DateTime? lastSyncedAt;

  /// When this calendar was last updated.
  final DateTime? updatedAt;

  /// Converts this [Calendar] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'timeZone': timeZone,
      'isEnabled': isEnabled,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [Calendar] with the given fields replaced.
  Calendar copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? timeZone,
    bool? isEnabled,
    String? source,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    DateTime? updatedAt,
  }) {
    return Calendar(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      timeZone: timeZone ?? this.timeZone,
      isEnabled: isEnabled ?? this.isEnabled,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Calendar &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.color == color &&
        other.timeZone == timeZone &&
        other.isEnabled == isEnabled &&
        other.source == source &&
        other.createdAt == createdAt &&
        other.lastSyncedAt == lastSyncedAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      color,
      timeZone,
      isEnabled,
      source,
      createdAt,
      lastSyncedAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Calendar('
        'id: $id, '
        'name: $name, '
        'description: $description, '
        'color: $color, '
        'timeZone: $timeZone, '
        'isEnabled: $isEnabled, '
        'source: $source, '
        'createdAt: $createdAt, '
        'lastSyncedAt: $lastSyncedAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}