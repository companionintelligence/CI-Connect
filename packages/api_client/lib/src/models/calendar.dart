/// {@template calendar}
/// A calendar entity that represents a calendar to be synced.
/// {@endtemplate}
class Calendar {
  /// {@macro calendar}
  const Calendar({
    required this.id,
    required this.name,
    this.description,
    required this.isEnabled,
    required this.source,
    this.lastSyncedAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a [Calendar] instance from a JSON map.
  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isEnabled: json['isEnabled'] as bool,
      source: json['source'] as String,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// The unique identifier of the calendar.
  final String id;

  /// The display name of the calendar.
  final String name;

  /// An optional description of the calendar.
  final String? description;

  /// Whether the calendar is enabled for syncing.
  final bool isEnabled;

  /// The source system of the calendar (e.g., 'google', 'outlook', 'apple').
  final String source;

  /// The timestamp when the calendar was last synchronized.
  final DateTime? lastSyncedAt;

  /// The timestamp when the calendar was created.
  final DateTime createdAt;

  /// The timestamp when the calendar was last updated.
  final DateTime? updatedAt;

  /// Converts the [Calendar] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isEnabled': isEnabled,
      'source': source,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [Calendar] with the given fields replaced.
  Calendar copyWith({
    String? id,
    String? name,
    String? description,
    bool? isEnabled,
    String? source,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Calendar(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      source: source ?? this.source,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Calendar &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          isEnabled == other.isEnabled &&
          source == other.source &&
          lastSyncedAt == other.lastSyncedAt &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        isEnabled,
        source,
        lastSyncedAt,
        createdAt,
        updatedAt,
      );
}