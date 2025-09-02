import 'package:json_annotation/json_annotation.dart';

part 'place.g.dart';

/// Place model for CI-Server API
@JsonSerializable()
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
  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

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
  Map<String, dynamic> toJson() => _$PlaceToJson(this);

  @override
  String toString() {
    return 'Place(id: $id, name: $name, address: $address)';
  }
}