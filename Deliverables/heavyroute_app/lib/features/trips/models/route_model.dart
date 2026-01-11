import 'package:json_annotation/json_annotation.dart';

part 'route_model.g.dart';

@JsonSerializable()
class RouteModel {
  final int id;

  // Backend field: routeDistance (Double)
  final double routeDistance;

  // Backend field: routeDuration (Double - minuti)
  final double routeDuration;

  // Stringa codificata per disegnare la linea su Mapbox
  final String polyline;

  RouteModel({
    required this.id,
    required this.routeDistance,
    required this.routeDuration,
    required this.polyline,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => _$RouteModelFromJson(json);
  Map<String, dynamic> toJson() => _$RouteModelToJson(this);
}