/// {@template calendar_event}
/// A calendar event entity that represents an event within a calendar.
/// {@endtemplate}
class CalendarEvent {
  /// {@macro calendar_event}
  const CalendarEvent({
    required this.id,
    required this.calendarId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.location,
    this.attendees = const [],
    required this.source,
    this.sourceEventId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a [CalendarEvent] instance from a JSON map.
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      calendarId: json['calendarId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAllDay: json['isAllDay'] as bool? ?? false,
      location: json['location'] as String?,
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      source: json['source'] as String,
      sourceEventId: json['sourceEventId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// The unique identifier of the calendar event.
  final String id;

  /// The ID of the calendar this event belongs to.
  final String calendarId;

  /// The title of the event.
  final String title;

  /// An optional description of the event.
  final String? description;

  /// The start date and time of the event.
  final DateTime startTime;

  /// The end date and time of the event.
  final DateTime endTime;

  /// Whether this is an all-day event.
  final bool isAllDay;

  /// The location of the event.
  final String? location;

  /// The list of attendees for the event.
  final List<String> attendees;

  /// The source system of the event (e.g., 'google', 'outlook', 'apple').
  final String source;

  /// The original event ID from the source system.
  final String? sourceEventId;

  /// The timestamp when the event was created.
  final DateTime createdAt;

  /// The timestamp when the event was last updated.
  final DateTime? updatedAt;

  /// Converts the [CalendarEvent] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calendarId': calendarId,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
      'location': location,
      'attendees': attendees,
      'source': source,
      'sourceEventId': sourceEventId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [CalendarEvent] with the given fields replaced.
  CalendarEvent copyWith({
    String? id,
    String? calendarId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? location,
    List<String>? attendees,
    String? source,
    String? sourceEventId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      calendarId: calendarId ?? this.calendarId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      source: source ?? this.source,
      sourceEventId: sourceEventId ?? this.sourceEventId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          calendarId == other.calendarId &&
          title == other.title &&
          description == other.description &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          isAllDay == other.isAllDay &&
          location == other.location &&
          attendees == other.attendees &&
          source == other.source &&
          sourceEventId == other.sourceEventId &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        calendarId,
        title,
        description,
        startTime,
        endTime,
        isAllDay,
        location,
        attendees,
        source,
        sourceEventId,
        createdAt,
        updatedAt,
      );
}