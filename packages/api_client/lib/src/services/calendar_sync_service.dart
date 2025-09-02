import 'dart:math';

import 'package:api_client/src/models/models.dart';
import 'package:api_client/src/services/ci_server_api_client.dart';

/// {@template calendar_sync_service}
/// Service for syncing calendars and calendar events with the CI-Server API.
/// {@endtemplate}
class CalendarSyncService {
  /// {@macro calendar_sync_service}
  CalendarSyncService({
    required CIServerApiClient apiClient,
  }) : _apiClient = apiClient;

  final CIServerApiClient _apiClient;

  /// Copies and syncs all calendars for a studio to the CI-Server API.
  ///
  /// This method will:
  /// 1. Fetch all calendars from external sources
  /// 2. Store/update them in the CI-Server via the content API
  /// 3. Sync all events for each calendar
  ///
  /// Returns a list of synced [Calendar] objects.
  Future<List<Calendar>> syncAllCalendars({
    required String studioId,
  }) async {
    try {
      // Fetch calendars from external sources
      final calendarsToSync = await _fetchCalendarsFromSources();
      final syncedCalendars = <Calendar>[];

      for (final calendar in calendarsToSync) {
        final syncedCalendar = await _syncCalendar(
          studioId: studioId,
          calendar: calendar,
        );
        syncedCalendars.add(syncedCalendar);

        // Sync events for this calendar
        await _syncCalendarEvents(
          studioId: studioId,
          calendarId: calendar.id,
        );
      }

      return syncedCalendars;
    } catch (e) {
      throw CalendarSyncException('Failed to sync calendars: $e');
    }
  }

  /// Syncs a specific calendar to the CI-Server API.
  Future<Calendar> syncCalendar({
    required String studioId,
    required String calendarId,
  }) async {
    try {
      // Fetch calendar from external source
      final calendar = await _fetchCalendarFromSource(calendarId);
      
      // Store/update in CI-Server via content API
      final syncedCalendar = await _syncCalendar(
        studioId: studioId,
        calendar: calendar,
      );

      // Sync events for this calendar
      await _syncCalendarEvents(
        studioId: studioId,
        calendarId: calendarId,
      );

      return syncedCalendar;
    } catch (e) {
      throw CalendarSyncException('Failed to sync calendar $calendarId: $e');
    }
  }

  /// Gets all synced calendars for a studio from the CI-Server API.
  Future<List<Calendar>> getCalendars({
    required String studioId,
  }) async {
    try {
      // Using the 'content' endpoint as it's one of the mentioned CI-Server endpoints
      // and calendars are a type of content
      final response = await _apiClient.getAll(
        'api/content/calendars',
        queryParameters: {'studio_id': studioId},
      );

      return response
          .map((json) => Calendar.fromJson(json))
          .toList();
    } catch (e) {
      throw CalendarSyncException('Failed to fetch calendars: $e');
    }
  }

  /// Gets all events for a specific calendar from the CI-Server API.
  Future<List<CalendarEvent>> getCalendarEvents({
    required String studioId,
    required String calendarId,
  }) async {
    try {
      // Using the 'content' endpoint for calendar events
      final response = await _apiClient.getAll(
        'api/content/calendar-events',
        queryParameters: {
          'studio_id': studioId,
          'calendar_id': calendarId,
        },
      );

      return response
          .map((json) => CalendarEvent.fromJson(json))
          .toList();
    } catch (e) {
      throw CalendarSyncException('Failed to fetch calendar events: $e');
    }
  }

  /// Internal method to fetch calendars from external sources.
  /// This would integrate with actual calendar APIs in a real implementation.
  Future<List<Calendar>> _fetchCalendarsFromSources() async {
    // TODO: Integrate with actual calendar sources (Google Calendar, Outlook, etc.)
    // For now, return sample calendars for demonstration
    return [
      Calendar(
        id: _generateId(),
        name: 'Sample Google Calendar',
        description: 'A sample Google Calendar for demonstration',
        color: '#4285F4',
        timeZone: 'America/New_York',
        isEnabled: true,
        source: 'google',
        createdAt: DateTime.now(),
      ),
      Calendar(
        id: _generateId(),
        name: 'Sample Outlook Calendar',
        description: 'A sample Outlook Calendar for demonstration',
        color: '#0078D4',
        timeZone: 'America/New_York',
        isEnabled: true,
        source: 'outlook',
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Internal method to fetch a specific calendar from external source.
  Future<Calendar> _fetchCalendarFromSource(String calendarId) async {
    // TODO: Integrate with actual calendar source API
    // For now, create a placeholder calendar
    return Calendar(
      id: calendarId,
      name: 'Sample Calendar',
      description: 'A sample calendar for demonstration',
      isEnabled: true,
      source: 'demo',
      createdAt: DateTime.now(),
    );
  }

  /// Internal method to sync a calendar to CI-Server.
  Future<Calendar> _syncCalendar({
    required String studioId,
    required Calendar calendar,
  }) async {
    final updatedCalendar = calendar.copyWith(
      lastSyncedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final calendarData = {
      ...updatedCalendar.toJson(),
      'studio_id': studioId,
    };

    try {
      // Try to update existing calendar first
      await _apiClient.update(
        'api/content/calendars',
        calendar.id,
        calendarData,
      );
    } on CIServerApiException {
      // If update fails, try to create new calendar
      await _apiClient.create('api/content/calendars', calendarData);
    }

    return updatedCalendar;
  }

  /// Internal method to sync calendar events.
  Future<void> _syncCalendarEvents({
    required String studioId,
    required String calendarId,
  }) async {
    // TODO: Fetch events from external calendar source
    // and sync them to CI-Server via content API
    
    // For demonstration, create some sample events
    final sampleEvents = await _fetchEventsFromSource(calendarId);
    
    for (final event in sampleEvents) {
      final eventData = {
        ...event.toJson(),
        'studio_id': studioId,
      };

      try {
        // Try to update existing event first
        await _apiClient.update(
          'api/content/calendar-events',
          event.id,
          eventData,
        );
      } on CIServerApiException {
        // If update fails, try to create new event
        await _apiClient.create('api/content/calendar-events', eventData);
      }
    }
  }

  /// Internal method to fetch events from external source.
  Future<List<CalendarEvent>> _fetchEventsFromSource(String calendarId) async {
    // TODO: Integrate with actual calendar source API
    // For now, create sample events for demonstration
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: _generateId(),
        calendarId: calendarId,
        title: 'Sample Meeting',
        description: 'A sample calendar event',
        location: 'Conference Room A',
        startDateTime: now.add(const Duration(days: 1)),
        endDateTime: now.add(const Duration(days: 1, hours: 1)),
        isAllDay: false,
        attendees: [
          const CalendarAttendee(
            email: 'attendee@example.com',
            name: 'John Doe',
            responseStatus: 'accepted',
          ),
        ],
        status: 'confirmed',
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Generates a unique ID for calendar and event entities.
  static const int idLength = 20;
  String _generateId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(idLength, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}

/// Exception thrown when calendar sync operations fail.
class CalendarSyncException implements Exception {
  /// Creates a [CalendarSyncException] with the given [message].
  const CalendarSyncException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'CalendarSyncException: $message';
}