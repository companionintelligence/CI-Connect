import 'package:json_annotation/json_annotation.dart';

part 'person.g.dart';

/// Person model for CI-Server API
@JsonSerializable()
class Person {
  /// Creates a [Person] instance.
  const Person({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [Person] from a JSON map.
  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  /// Unique identifier for the person
  final String id;

  /// Full name of the person
  final String name;

  /// Email address
  final String? email;

  /// Phone number
  final String? phone;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => _$PersonToJson(this);

  @override
  String toString() {
    return 'Person(id: $id, name: $name, email: $email)';
  }
}