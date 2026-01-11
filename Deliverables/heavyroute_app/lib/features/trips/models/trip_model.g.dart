// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripModel _$TripModelFromJson(Map<String, dynamic> json) => TripModel(
  id: (json['id'] as num).toInt(),
  tripCode: json['tripCode'] as String,
  status: $enumDecode(
    _$TripStatusEnumMap,
    json['status'],
    unknownValue: TripStatus.IN_PLANNING,
  ),
  request: TransportRequest.fromJson(json['request'] as Map<String, dynamic>),
  route: json['route'] == null
      ? null
      : RouteModel.fromJson(json['route'] as Map<String, dynamic>),
  driver: json['driver'] == null
      ? null
      : UserModel.fromJson(json['driver'] as Map<String, dynamic>),
  vehicle: json['vehicle'] == null
      ? null
      : VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TripModelToJson(TripModel instance) => <String, dynamic>{
  'id': instance.id,
  'tripCode': instance.tripCode,
  'status': _$TripStatusEnumMap[instance.status]!,
  'request': instance.request,
  'route': instance.route,
  'driver': instance.driver,
  'vehicle': instance.vehicle,
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
