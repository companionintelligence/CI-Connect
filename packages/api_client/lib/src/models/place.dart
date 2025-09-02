/// Place model for CI-Server API
class Place {
  /// Creates a [Place] instance.
  const Place({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [Place] from a JSON map.
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Unique identifier for the place
  final String id;

  /// Name of the place
  final String name;

  /// Physical address
  final String? address;

  /// Latitude coordinate
  final double? latitude;

  /// Longitude coordinate
  final double? longitude;

  /// Description of the place
  final String? description;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (description != null) 'description': description,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Place(id: $id, name: $name, address: $address)';
  }
}