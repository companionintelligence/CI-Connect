import 'package:api_client/api_client.dart';

class Location {
  final String? id;
  final String? name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime? timestamp;
  final String? address;
  final String? city;
  final String? region;
  final String? country;
  final String? postalCode;
  final String? provider;
  final bool? isFromMockProvider;
  final String? source;

  const Location({
    this.id,
    this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.timestamp,
    this.address,
    this.city,
    this.region,
    this.country,
    this.postalCode,
    this.provider,
    this.isFromMockProvider,
    this.source,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: JsonUtils.parseString(json['id']),
      name: JsonUtils.parseString(json['name']),
      description: JsonUtils.parseString(json['description']),
      latitude: JsonUtils.parseDouble(json['latitude']),
      longitude: JsonUtils.parseDouble(json['longitude']),
      accuracy: JsonUtils.parseDouble(json['accuracy']),
      altitude: JsonUtils.parseDouble(json['altitude']),
      speed: JsonUtils.parseDouble(json['speed']),
      heading: JsonUtils.parseDouble(json['heading']),
      timestamp: JsonUtils.parseDateTime(json['timestamp']),
      address: JsonUtils.parseString(json['address']),
      city: JsonUtils.parseString(json['city']),
      region: JsonUtils.parseString(json['region']),
      country: JsonUtils.parseString(json['country']),
      postalCode: JsonUtils.parseString(json['postalCode']),
      provider: JsonUtils.parseString(json['provider']),
      isFromMockProvider: JsonUtils.parseBool(json['isFromMockProvider']),
      source: JsonUtils.parseString(json['source']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    // Only include non-null and non-empty values
    if (id != null && id!.isNotEmpty) json['id'] = id;
    if (name != null && name!.isNotEmpty) json['name'] = name;
    if (description != null && description!.isNotEmpty) json['description'] = description;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (accuracy != null) json['accuracy'] = accuracy;
    if (altitude != null) json['altitude'] = altitude;
    if (speed != null) json['speed'] = speed;
    if (heading != null) json['heading'] = heading;
    if (timestamp != null) json['timestamp'] = timestamp!.toIso8601String();
    if (address != null && address!.isNotEmpty) json['address'] = address;
    if (city != null && city!.isNotEmpty) json['city'] = city;
    if (region != null && region!.isNotEmpty) json['region'] = region;
    if (country != null && country!.isNotEmpty) json['country'] = country;
    if (postalCode != null && postalCode!.isNotEmpty) json['postalCode'] = postalCode;
    if (provider != null && provider!.isNotEmpty) json['provider'] = provider;
    if (isFromMockProvider != null) json['isFromMockProvider'] = isFromMockProvider;
    if (source != null && source!.isNotEmpty) json['source'] = source;

    return json;
  }
}
