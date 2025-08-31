import 'package:api_client/src/firebase_extensions.dart';
import 'package:api_client/src/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// {@template calendar_sync_service}
/// Service for syncing calendars and calendar events to the CI-Server API.
/// {@endtemplate}
class CalendarSyncService {
  /// {@macro calendar_sync_service}
  CalendarSyncService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Copies and syncs all calendars for a studio to the CI-Server API.
  ///
  /// This method will:
  /// 1. Fetch all calendars from external sources
  /// 2. Store/update them in Firestore
  /// 3. Sync all events for each calendar
  ///
  /// Returns a list of synced [Calendar] objects.
  Future<List<Calendar>> syncAllCalendars({
    required String studioId,
  }) async {
    try {
      // This is where external calendar sources would be integrated
      // For now, we'll create a basic implementation that demonstrates
      // the structure for future integration
      
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
      
      // Store/update in Firestore
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

  /// Gets all synced calendars for a studio.
  Future<List<Calendar>> getCalendars({
    required String studioId,
  }) async {
    try {
      final snapshot = await _firestore
          .calendarsCollection(studioId: studioId)
          .get();

      return snapshot.docs
          .map((doc) => Calendar.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw CalendarSyncException('Failed to fetch calendars: $e');
    }
  }

  /// Gets all events for a specific calendar.
  Future<List<CalendarEvent>> getCalendarEvents({
    required String studioId,
    required String calendarId,
  }) async {
    try {
      final snapshot = await _firestore
          .calendarEventsCollection(
            studioId: studioId,
            calendarId: calendarId,
          )
          .get();

      return snapshot.docs
          .map((doc) => CalendarEvent.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw CalendarSyncException('Failed to fetch calendar events: $e');
    }
  }

  /// Internal method to fetch calendars from external sources.
  /// This would integrate with actual calendar APIs in a real implementation.
  Future<List<Calendar>> _fetchCalendarsFromSources() async {
    // TODO: Integrate with actual calendar sources (Google Calendar, Outlook, etc.)
    // For now, return an empty list as a placeholder
    return [];
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

  /// Internal method to sync a calendar to Firestore.
  Future<Calendar> _syncCalendar({
    required String studioId,
    required Calendar calendar,
  }) async {
    final updatedCalendar = calendar.copyWith(
      lastSyncedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .calendarDoc(studioId: studioId, calendarId: calendar.id)
        .set(updatedCalendar.toJson());

    return updatedCalendar;
  }

  /// Internal method to sync calendar events.
  Future<void> _syncCalendarEvents({
    required String studioId,
    required String calendarId,
  }) async {
    // TODO: Fetch events from external calendar source
    // and sync them to Firestore
    // For now, this is a placeholder
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