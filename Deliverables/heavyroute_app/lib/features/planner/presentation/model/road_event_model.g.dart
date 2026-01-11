// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'road_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadEventModel _$RoadEventModelFromJson(Map<String, dynamic> json) =>
    RoadEventModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      active: json['active'] as bool,
      blocking: json['blocking'] as bool,
      validFrom: json['validFrom'] as String,
      validTo: json['validTo'] as String,
    );

Map<String, dynamic> _$RoadEventModelToJson(RoadEventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'severity': instance.severity,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'active': instance.active,
      'blocking': instance.blocking,
      'validFrom': instance.validFrom,
      'validTo': instance.validTo,
    };
