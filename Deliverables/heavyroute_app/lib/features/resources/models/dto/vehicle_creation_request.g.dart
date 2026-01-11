// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_creation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$VehicleCreationRequestToJson(
  VehicleCreationRequest instance,
) => <String, dynamic>{
  'licensePlate': instance.licensePlate,
  'model': instance.model,
  'maxLoadCapacity': instance.maxLoadCapacity,
  'maxHeight': instance.maxHeight,
  'maxWidth': instance.maxWidth,
  'maxLength': instance.maxLength,
  'status': _$VehicleStatusEnumMap[instance.status]!,
};

const _$VehicleStatusEnumMap = {
  VehicleStatus.AVAILABLE: 'AVAILABLE',
  VehicleStatus.IN_USE: 'IN_USE',
  VehicleStatus.MAINTENANCE: 'MAINTENANCE',
  VehicleStatus.DECOMMISSIONED: 'DECOMMISSIONED',
};
