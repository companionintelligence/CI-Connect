/// Utility functions for safe JSON parsing
class JsonUtils {
  /// Safely parses a JSON value to String
  static String parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  /// Safely parses a JSON value to int
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely parses a JSON value to double
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Safely parses a JSON value to bool
  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  /// Safely parses a JSON value to DateTime
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  /// Safely parses a JSON value to List<T>
  static List<T> parseList<T>(
    dynamic value,
    T Function(dynamic) itemParser, {
    List<T> defaultValue = const [],
  }) {
    if (value == null) return defaultValue;
    if (value is! List) return defaultValue;

    try {
      return value.map((item) => itemParser(item)).toList();
    } catch (e) {
      return defaultValue;
    }
  }

  /// Safely parses a JSON value to Map<String, dynamic>
  static Map<String, dynamic> parseMap(
    dynamic value, {
    Map<String, dynamic> defaultValue = const {},
  }) {
    if (value == null) return defaultValue;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return defaultValue;
  }

  /// Safely extracts a nested value from JSON using dot notation
  /// Example: extractNested(json, 'user.profile.name')
  static dynamic extractNested(Map<String, dynamic> json, String path) {
    final parts = path.split('.');
    dynamic current = json;

    for (final part in parts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }

    return current;
  }

  /// Safely extracts a nested string value
  static String extractNestedString(
    Map<String, dynamic> json,
    String path, {
    String defaultValue = '',
  }) {
    final value = extractNested(json, path);
    return parseString(value, defaultValue: defaultValue);
  }

  /// Safely extracts a nested int value
  static int extractNestedInt(
    Map<String, dynamic> json,
    String path, {
    int defaultValue = 0,
  }) {
    final value = extractNested(json, path);
    return parseInt(value, defaultValue: defaultValue);
  }
}
