// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
  id: (json['id'] as num).toInt(),
  licensePlate: json['licensePlate'] as String,
  model: json['model'] as String,
  maxLoadCapacity: (json['maxLoadCapacity'] as num).toDouble(),
  maxHeight: (json['maxHeight'] as num).toDouble(),
  maxWidth: (json['maxWidth'] as num).toDouble(),
  maxLength: (json['maxLength'] as num).toDouble(),
  status: $enumDecode(
    _$VehicleStatusEnumMap,
    json['status'],
    unknownValue: VehicleStatus.AVAILABLE,
  ),
  available: json['available'] as bool,
  inMaintenance: json['inMaintenance'] as bool,
);

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'licensePlate': instance.licensePlate,
      'model': instance.model,
      'maxLoadCapacity': instance.maxLoadCapacity,
      'maxHeight': instance.maxHeight,
      'maxWidth': instance.maxWidth,
      'maxLength': instance.maxLength,
      'status': _$VehicleStatusEnumMap[instance.status]!,
      'available': instance.available,
      'inMaintenance': instance.inMaintenance,
    };

const _$VehicleStatusEnumMap = {
  VehicleStatus.AVAILABLE: 'AVAILABLE',
  VehicleStatus.IN_USE: 'IN_USE',
  VehicleStatus.MAINTENANCE: 'MAINTENANCE',
  VehicleStatus.DECOMMISSIONED: 'DECOMMISSIONED',
};
