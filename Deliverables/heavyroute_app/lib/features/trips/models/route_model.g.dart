// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => RouteModel(
  id: (json['id'] as num).toInt(),
  description: json['description'] as String? ?? 'Percorso Standard',
  distanceKm:
      (RouteModel._readDistance(json, 'distance') as num?)?.toDouble() ?? 0.0,
  durationHours: _minutesToHours(
    RouteModel._readDuration(json, 'duration') as num?,
  ),
  tollCost: (json['tollCost'] as num?)?.toDouble() ?? 0.0,
  isHazmatSuitable: json['isHazmatSuitable'] as bool? ?? true,
  polyline: RouteModel._readPolyline(json, 'polyline') as String? ?? '',
  startLat: (RouteModel._readStartLat(json, 'startLat') as num?)?.toDouble(),
  startLon: (RouteModel._readStartLon(json, 'startLon') as num?)?.toDouble(),
  endLat: (RouteModel._readEndLat(json, 'endLat') as num?)?.toDouble(),
  endLon: (RouteModel._readEndLon(json, 'endLon') as num?)?.toDouble(),
);

Map<String, dynamic> _$RouteModelToJson(RouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'distance': instance.distanceKm,
      'duration': instance.durationHours,
      'tollCost': instance.tollCost,
      'isHazmatSuitable': instance.isHazmatSuitable,
      'polyline': instance.polyline,
      'startLat': instance.startLat,
      'startLon': instance.startLon,
      'endLat': instance.endLat,
      'endLon': instance.endLon,
    };
