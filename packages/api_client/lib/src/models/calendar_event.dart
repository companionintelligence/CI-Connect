/// {@template calendar_event}
/// A calendar event entity that represents an event from external calendar sources.
/// {@endtemplate}
class CalendarEvent {
  /// {@macro calendar_event}
  const CalendarEvent({
    required this.id,
    required this.calendarId,
    required this.title,
    required this.startDateTime,
    required this.endDateTime,
    this.description,
    this.location,
    this.isAllDay = false,
    this.attendees,
    this.recurrenceRule,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [CalendarEvent] from a JSON map.
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      calendarId: json['calendarId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: DateTime.parse(json['endDateTime'] as String),
      isAllDay: json['isAllDay'] as bool? ?? false,
      attendees: (json['attendees'] as List<dynamic>?)
          ?.map((attendee) => CalendarAttendee.fromJson(attendee as Map<String, dynamic>))
          .toList(),
      recurrenceRule: json['recurrenceRule'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// The unique identifier for this event.
  final String id;

  /// The ID of the calendar this event belongs to.
  final String calendarId;

  /// The title/summary of the event.
  final String title;

  /// Optional description of the event.
  final String? description;

  /// The location of the event.
  final String? location;

  /// The start date and time of the event.
  final DateTime startDateTime;

  /// The end date and time of the event.
  final DateTime endDateTime;

  /// Whether this is an all-day event.
  final bool isAllDay;

  /// List of attendees for this event.
  final List<CalendarAttendee>? attendees;

  /// The recurrence rule for recurring events (RFC 5545 format).
  final String? recurrenceRule;

  /// The status of the event (e.g., "confirmed", "tentative", "cancelled").
  final String? status;

  /// When this event was created.
  final DateTime? createdAt;

  /// When this event was last updated.
  final DateTime? updatedAt;

  /// Converts this [CalendarEvent] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'calendarId': calendarId,
      'title': title,
      'description': description,
      'location': location,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'isAllDay': isAllDay,
      'attendees': attendees?.map((attendee) => attendee.toJson()).toList(),
      'recurrenceRule': recurrenceRule,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [CalendarEvent] with the given fields replaced.
  CalendarEvent copyWith({
    String? id,
    String? calendarId,
    String? title,
    String? description,
    String? location,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? isAllDay,
    List<CalendarAttendee>? attendees,
    String? recurrenceRule,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      calendarId: calendarId ?? this.calendarId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isAllDay: isAllDay ?? this.isAllDay,
      attendees: attendees ?? this.attendees,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEvent &&
        other.id == id &&
        other.calendarId == calendarId &&
        other.title == title &&
        other.description == description &&
        other.location == location &&
        other.startDateTime == startDateTime &&
        other.endDateTime == endDateTime &&
        other.isAllDay == isAllDay &&
        other.recurrenceRule == recurrenceRule &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      calendarId,
      title,
      description,
      location,
      startDateTime,
      endDateTime,
      isAllDay,
      recurrenceRule,
      status,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'CalendarEvent('
        'id: $id, '
        'calendarId: $calendarId, '
        'title: $title, '
        'description: $description, '
        'location: $location, '
        'startDateTime: $startDateTime, '
        'endDateTime: $endDateTime, '
        'isAllDay: $isAllDay, '
        'attendees: $attendees, '
        'recurrenceRule: $recurrenceRule, '
        'status: $status, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}

/// {@template calendar_attendee}
/// Represents an attendee of a calendar event.
/// {@endtemplate}
class CalendarAttendee {
  /// {@macro calendar_attendee}
  const CalendarAttendee({
    required this.email,
    this.name,
    this.responseStatus,
    this.isOptional = false,
  });

  /// Creates a [CalendarAttendee] from a JSON map.
  factory CalendarAttendee.fromJson(Map<String, dynamic> json) {
    return CalendarAttendee(
      email: json['email'] as String,
      name: json['name'] as String?,
      responseStatus: json['responseStatus'] as String?,
      isOptional: json['isOptional'] as bool? ?? false,
    );
  }

  /// The email address of the attendee.
  final String email;

  /// The display name of the attendee.
  final String? name;

  /// The response status of the attendee (e.g., "accepted", "declined", "tentative", "needsAction").
  final String? responseStatus;

  /// Whether this attendee is optional.
  final bool isOptional;

  /// Converts this [CalendarAttendee] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'responseStatus': responseStatus,
      'isOptional': isOptional,
    };
  }

  /// Creates a copy of this [CalendarAttendee] with the given fields replaced.
  CalendarAttendee copyWith({
    String? email,
    String? name,
    String? responseStatus,
    bool? isOptional,
  }) {
    return CalendarAttendee(
      email: email ?? this.email,
      name: name ?? this.name,
      responseStatus: responseStatus ?? this.responseStatus,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarAttendee &&
        other.email == email &&
        other.name == name &&
        other.responseStatus == responseStatus &&
        other.isOptional == isOptional;
  }

  @override
  int get hashCode {
    return Object.hash(email, name, responseStatus, isOptional);
  }

  @override
  String toString() {
    return 'CalendarAttendee('
        'email: $email, '
        'name: $name, '
        'responseStatus: $responseStatus, '
        'isOptional: $isOptional'
        ')';
  }
}