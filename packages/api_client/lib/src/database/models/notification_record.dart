/// {@template notification_record}
/// Local storage record for notifications.
/// {@endtemplate}
class NotificationRecord {
  /// {@macro notification_record}
  const NotificationRecord({
    required this.id,
    required this.title,
    this.body,
    this.type,
    this.data,
    this.isRead = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [NotificationRecord] from a database map.
  factory NotificationRecord.fromDatabaseMap(Map<String, dynamic> map) {
    return NotificationRecord(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String?,
      type: map['type'] as String?,
      data: map['data'] as String?,
      isRead: (map['read'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Unique identifier
  final String id;

  /// Notification title
  final String title;

  /// Notification body text
  final String? body;

  /// Type of notification
  final String? type;

  /// Additional data as JSON string
  final String? data;

  /// Whether the notification has been read
  final bool isRead;

  /// When the notification was created
  final DateTime? createdAt;

  /// When the notification was last updated
  final DateTime? updatedAt;

  /// Converts to a map for database storage
  Map<String, dynamic> toDatabaseMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'read': isRead ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy with updated information
  NotificationRecord copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationRecord(id: $id, title: $title, type: $type, isRead: $isRead)';
  }
}