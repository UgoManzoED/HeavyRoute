import 'package:json_annotation/json_annotation.dart';

part 'route_model.g.dart';

// Helper per convertire minuti in ore
double _minutesToHours(num? value) {
  if (value == null) return 0.0;
  return value.toDouble() / 60.0;
}

@JsonSerializable()
class RouteModel {
  final int id;

  @JsonKey(defaultValue: "Percorso Standard")
  final String description;

  @JsonKey(name: 'distance', readValue: _readDistance, defaultValue: 0.0)
  final double distanceKm;

  @JsonKey(name: 'duration', fromJson: _minutesToHours, readValue: _readDuration)
  final double durationHours;

  @JsonKey(defaultValue: 0.0)
  final double tollCost;

  @JsonKey(defaultValue: true)
  final bool isHazmatSuitable;

  // FIX 3: Cerca 'polyline', 'geometry', o 'encodedPolyline'
  @JsonKey(name: 'polyline', readValue: _readPolyline, defaultValue: "")
  final String polyline;

  // FIX 4: Coordinate - Gestione robusta per camelCase e snake_case
  @JsonKey(name: 'startLat', readValue: _readStartLat)
  final double? startLat;

  @JsonKey(name: 'startLon', readValue: _readStartLon)
  final double? startLon;

  @JsonKey(name: 'endLat', readValue: _readEndLat)
  final double? endLat;

  @JsonKey(name: 'endLon', readValue: _readEndLon)
  final double? endLon;

  RouteModel({
    required this.id,
    required this.description,
    required this.distanceKm,
    required this.durationHours,
    required this.tollCost,
    required this.isHazmatSuitable,
    required this.polyline,
    this.startLat,
    this.startLon,
    this.endLat,
    this.endLon,
  });

  String get formattedDuration {
    final int hours = durationHours.floor();
    final int minutes = ((durationHours - hours) * 60).round();
    return minutes > 0 ? "${hours}h ${minutes}m" : "${hours}h";
  }

  factory RouteModel.fromJson(Map<String, dynamic> json) => _$RouteModelFromJson(json);
  Map<String, dynamic> toJson() => _$RouteModelToJson(this);

  // --- LETTORI INTELLIGENTI ---

  static Object? _readDistance(Map json, String key) {
    return json['distance'] ?? json['routeDistance'] ?? json['distance_km'] ?? 0.0;
  }

  static Object? _readDuration(Map json, String key) {
    return json['duration'] ?? json['routeDuration'] ?? json['duration_minutes'] ?? 0.0;
  }

  static Object? _readPolyline(Map json, String key) {
    return json['polyline'] ?? json['geometry'] ?? "";
  }

  static Object? _readStartLat(Map json, String key) {
    return json['startLat'] ?? json['start_lat'] ?? json['latitude'];
  }

  static Object? _readStartLon(Map json, String key) {
    return json['startLon'] ?? json['start_lon'] ?? json['longitude'];
  }

  static Object? _readEndLat(Map json, String key) {
    return json['endLat'] ?? json['end_lat'];
  }

  static Object? _readEndLon(Map json, String key) {
    return json['endLon'] ?? json['end_lon'];
  }
}