// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransportRequest _$TransportRequestFromJson(Map<String, dynamic> json) =>
    TransportRequest(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      client: UserModel.fromJson(json['client'] as Map<String, dynamic>),
      originAddress: json['originAddress'] as String,
      destinationAddress: json['destinationAddress'] as String,
      pickupDate: DateTime.parse(json['pickupDate'] as String),
      requestStatus: $enumDecode(_$RequestStatusEnumMap, json['requestStatus']),
      load: LoadDetails.fromJson(json['load'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TransportRequestToJson(TransportRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'client': instance.client,
      'originAddress': instance.originAddress,
      'destinationAddress': instance.destinationAddress,
      'pickupDate': instance.pickupDate.toIso8601String(),
      'requestStatus': _$RequestStatusEnumMap[instance.requestStatus]!,
      'load': instance.load,
    };

const _$RequestStatusEnumMap = {
  RequestStatus.PENDING: 'PENDING',
  RequestStatus.APPROVED: 'APPROVED',
  RequestStatus.REJECTED: 'REJECTED',
  RequestStatus.CANCELLED: 'CANCELLED',
  RequestStatus.COMPLETED: 'COMPLETED',
};
