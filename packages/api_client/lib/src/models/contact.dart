/// Contact model for CI-Server API
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
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

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
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (company != null) 'company': company,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, company: $company)';
  }
}