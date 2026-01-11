import 'package:json_annotation/json_annotation.dart';

part 'route_model.g.dart';

double _minutesToHours(num? value) {
  if (value == null) return 0.0;
  return value.toDouble() / 60.0;
}

@JsonSerializable()
class RouteModel {
  final int id;

  // Campo descrittivo per la UI (es. "Veloce", "Ecologico")
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

  RouteModel({
    required this.id,
    required this.description,
    required this.distanceKm,
    required this.durationHours,
    required this.tollCost,
    required this.isHazmatSuitable,
    required this.polyline,
  });

  // Getter per formattare la durata in UI
  String get formattedDuration {
    final int hours = durationHours.floor();
    final int minutes = ((durationHours - hours) * 60).round();
    return "${hours}h ${minutes}m";
  }

  factory RouteModel.fromJson(Map<String, dynamic> json) => _$RouteModelFromJson(json);
  Map<String, dynamic> toJson() => _$RouteModelToJson(this);
}