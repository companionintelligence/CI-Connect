import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

/// Contact model for CI-Server API
@JsonSerializable()
class Contact {
  /// Creates a [Contact] instance.
  const Contact({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [Contact] from a JSON map.
  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);

  /// Unique identifier for the contact
  final String id;

  /// Full name of the contact
  final String name;

  /// Email address
  final String? email;

  /// Phone number
  final String? phone;

  /// Company name
  final String? company;

  /// Additional notes
  final String? notes;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, company: $company)';
  }
}