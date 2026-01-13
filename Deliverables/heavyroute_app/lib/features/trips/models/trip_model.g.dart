// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripModel _$TripModelFromJson(Map<String, dynamic> json) => TripModel(
  id: (json['id'] as num).toInt(),
  tripCode: json['tripCode'] as String? ?? 'N/D',
  status: $enumDecode(
    _$TripStatusEnumMap,
    json['status'],
    unknownValue: TripStatus.IN_PLANNING,
  ),
  request: TransportRequest.fromJson(json['request'] as Map<String, dynamic>),
  route: json['route'] == null
      ? null
      : RouteModel.fromJson(json['route'] as Map<String, dynamic>),
  driverId: (json['driverId'] as num?)?.toInt(),
  driverName: json['driverName'] as String?,
  driverSurname: json['driverSurname'] as String?,
  vehiclePlate: json['vehiclePlate'] as String?,
  vehicleModel: json['vehicleModel'] as String?,
);

Map<String, dynamic> _$TripModelToJson(TripModel instance) => <String, dynamic>{
  'id': instance.id,
  'tripCode': instance.tripCode,
  'status': _$TripStatusEnumMap[instance.status]!,
  'request': instance.request.toJson(),
  'route': instance.route?.toJson(),
  'driverId': instance.driverId,
  'driverName': instance.driverName,
  'driverSurname': instance.driverSurname,
  'vehiclePlate': instance.vehiclePlate,
  'vehicleModel': instance.vehicleModel,
};

const _$TripStatusEnumMap = {
  TripStatus.IN_PLANNING: 'IN_PLANNING',
  TripStatus.WAITING_VALIDATION: 'WAITING_VALIDATION',
  TripStatus.VALIDATED: 'VALIDATED',
  TripStatus.MODIFICATION_REQUESTED: 'MODIFICATION_REQUESTED',
  TripStatus.CONFIRMED: 'CONFIRMED',
  TripStatus.ACCEPTED: 'ACCEPTED',
  TripStatus.IN_TRANSIT: 'IN_TRANSIT',
  TripStatus.PAUSED: 'PAUSED',
  TripStatus.DELIVERING: 'DELIVERING',
  TripStatus.COMPLETED: 'COMPLETED',
  TripStatus.CANCELLED: 'CANCELLED',
};
