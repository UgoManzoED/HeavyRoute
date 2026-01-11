// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => RouteModel(
  id: (json['id'] as num).toInt(),
  routeDistance: (json['routeDistance'] as num).toDouble(),
  routeDuration: (json['routeDuration'] as num).toDouble(),
  polyline: json['polyline'] as String,
);

Map<String, dynamic> _$RouteModelToJson(RouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routeDistance': instance.routeDistance,
      'routeDuration': instance.routeDuration,
      'polyline': instance.polyline,
    };
