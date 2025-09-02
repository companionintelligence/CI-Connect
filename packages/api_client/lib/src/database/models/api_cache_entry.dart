/// {@template api_cache_entry}
/// Represents a cached API response for offline access.
/// {@endtemplate}
class ApiCacheEntry {
  /// {@macro api_cache_entry}
  const ApiCacheEntry({
    required this.key,
    required this.endpoint,
    required this.data,
    this.expiresAt,
    this.createdAt,
  });

  /// Creates an [ApiCacheEntry] from a database map.
  factory ApiCacheEntry.fromDatabaseMap(Map<String, dynamic> map) {
    return ApiCacheEntry(
      key: map['key'] as String,
      endpoint: map['endpoint'] as String,
      data: map['data'] as String,
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// Unique cache key
  final String key;

  /// API endpoint that was cached
  final String endpoint;

  /// Cached response data as JSON string
  final String data;

  /// When this cache entry expires
  final DateTime? expiresAt;

  /// When this cache entry was created
  final DateTime? createdAt;

  /// Whether this cache entry has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Whether this cache entry is still valid
  bool get isValid => !isExpired;

  /// Converts to a map for database storage
  Map<String, dynamic> toDatabaseMap() {
    return <String, dynamic>{
      'key': key,
      'endpoint': endpoint,
      'data': data,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy with updated information
  ApiCacheEntry copyWith({
    String? key,
    String? endpoint,
    String? data,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return ApiCacheEntry(
      key: key ?? this.key,
      endpoint: endpoint ?? this.endpoint,
      data: data ?? this.data,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ApiCacheEntry(key: $key, endpoint: $endpoint, '
        'isValid: $isValid, expiresAt: $expiresAt)';
  }
}