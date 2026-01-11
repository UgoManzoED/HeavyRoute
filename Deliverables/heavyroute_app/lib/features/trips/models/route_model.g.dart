// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => RouteModel(
  id: (json['id'] as num).toInt(),
  description: json['description'] as String? ?? 'Percorso Standard',
  distanceKm: (json['routeDistance'] as num).toDouble(),
  durationHours: (json['routeDuration'] as num).toDouble(),
  tollCost: (json['tollCost'] as num?)?.toDouble() ?? 0.0,
  isHazmatSuitable: json['isHazmatSuitable'] as bool? ?? true,
  polyline: json['polyline'] as String? ?? '',
);

Map<String, dynamic> _$RouteModelToJson(RouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'routeDistance': instance.distanceKm,
      'routeDuration': instance.durationHours,
      'tollCost': instance.tollCost,
      'isHazmatSuitable': instance.isHazmatSuitable,
      'polyline': instance.polyline,
    };
