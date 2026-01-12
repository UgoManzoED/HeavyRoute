import 'package:json_annotation/json_annotation.dart';

part 'route_model.g.dart';

double _minutesToHours(num? value) {
  if (value == null) return 0.0;
  return value.toDouble() / 60.0;
}

@JsonSerializable()
class RouteModel {
  final int id;

  @JsonKey(defaultValue: "Percorso Standard")
  final String description;

  // Backend: routeDistance | Service: distanceKm
  @JsonKey(name: 'routeDistance', defaultValue: 0.0)
  final double distanceKm;

  // Backend: routeDuration | Service: durationHours
  @JsonKey(name: 'routeDuration', fromJson: _minutesToHours)
  final double durationHours;

  // Campi extra calcolati nel frontend
  @JsonKey(defaultValue: 0.0)
  final double tollCost;

  @JsonKey(defaultValue: true)
  final bool isHazmatSuitable;

  // Stringa per disegnare la mappa
  @JsonKey(defaultValue: "")
  final String polyline;

  // --- CAMPI PER LA MAPPA ---
  final double? startLat;
  final double? startLon;
  final double? endLat;
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

  // Getter per formattare la durata in UI
  String get formattedDuration {
    final int hours = durationHours.floor();
    final int minutes = ((durationHours - hours) * 60).round();
    return minutes > 0 ? "${hours}h ${minutes}m" : "${hours}h";
  }

  factory RouteModel.fromJson(Map<String, dynamic> json) => _$RouteModelFromJson(json);
  Map<String, dynamic> toJson() => _$RouteModelToJson(this);
}