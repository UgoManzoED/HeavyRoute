// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoadDetails _$LoadDetailsFromJson(Map<String, dynamic> json) => LoadDetails(
  loadType: json['type'] as String? ?? 'Generico',
  description: json['description'] as String? ?? '',
  weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
  widthMeters: (json['width'] as num?)?.toDouble() ?? 0.0,
  heightMeters: (json['height'] as num?)?.toDouble() ?? 0.0,
  lengthMeters: (json['length'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$LoadDetailsToJson(LoadDetails instance) =>
    <String, dynamic>{
      'type': instance.loadType,
      'description': instance.description,
      'weightKg': instance.weightKg,
      'width': instance.widthMeters,
      'height': instance.heightMeters,
      'length': instance.lengthMeters,
    };
