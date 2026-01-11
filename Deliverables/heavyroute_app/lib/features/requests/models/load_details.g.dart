// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'load_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoadDetails _$LoadDetailsFromJson(Map<String, dynamic> json) => LoadDetails(
  type: json['type'] as String?,
  quantity: (json['quantity'] as num?)?.toInt(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
  width: (json['width'] as num?)?.toDouble(),
  length: (json['length'] as num?)?.toDouble(),
);

Map<String, dynamic> _$LoadDetailsToJson(LoadDetails instance) =>
    <String, dynamic>{
      'type': instance.type,
      'quantity': instance.quantity,
      'weightKg': instance.weightKg,
      'height': instance.height,
      'width': instance.width,
      'length': instance.length,
    };
