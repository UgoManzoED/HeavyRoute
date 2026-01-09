// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestCreationDTO _$RequestCreationDTOFromJson(Map<String, dynamic> json) =>
    RequestCreationDTO(
      originAddress: json['originAddress'] as String,
      destinationAddress: json['destinationAddress'] as String,
      pickupDate: json['pickupDate'] as String,
      weight: (json['weight'] as num).toDouble(),
      length: (json['length'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$RequestCreationDTOToJson(RequestCreationDTO instance) =>
    <String, dynamic>{
      'originAddress': instance.originAddress,
      'destinationAddress': instance.destinationAddress,
      'pickupDate': instance.pickupDate,
      'weight': instance.weight,
      'length': instance.length,
      'width': instance.width,
      'height': instance.height,
    };

RequestDetailDTO _$RequestDetailDTOFromJson(Map<String, dynamic> json) =>
    RequestDetailDTO(
      id: json['id'] as String?,
      originAddress: json['originAddress'] as String,
      destinationAddress: json['destinationAddress'] as String,
      pickupDate: json['pickupDate'] as String,
      weight: (json['weight'] as num).toDouble(),
      length: (json['length'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      status: $enumDecodeNullable(_$RequestStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$RequestDetailDTOToJson(RequestDetailDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'originAddress': instance.originAddress,
      'destinationAddress': instance.destinationAddress,
      'pickupDate': instance.pickupDate,
      'weight': instance.weight,
      'length': instance.length,
      'width': instance.width,
      'height': instance.height,
      'status': _$RequestStatusEnumMap[instance.status],
    };

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'PENDING',
  RequestStatus.approved: 'APPROVED',
  RequestStatus.rejected: 'REJECTED',
  RequestStatus.inTransit: 'IN_TRANSIT',
  RequestStatus.completed: 'COMPLETED',
};
