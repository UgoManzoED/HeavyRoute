// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestDetailDTO _$RequestDetailDTOFromJson(Map<String, dynamic> json) =>
    RequestDetailDTO(
      clientId: (json['clientId'] as num?)?.toInt(),
      clientFullName: json['clientFullName'] as String?,
      id: (json['id'] as num).toInt(),
      originAddress: json['originAddress'] as String,
      destinationAddress: json['destinationAddress'] as String,
      pickupDate: json['pickupDate'] as String,
      status: $enumDecodeNullable(
        _$RequestStatusEnumMap,
        json['status'],
        unknownValue: RequestStatus.pending,
      ),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      length: (json['length'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
    );

Map<String, dynamic> _$RequestDetailDTOToJson(RequestDetailDTO instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'clientFullName': instance.clientFullName,
      'id': instance.id,
      'originAddress': instance.originAddress,
      'destinationAddress': instance.destinationAddress,
      'pickupDate': instance.pickupDate,
      'status': _$RequestStatusEnumMap[instance.status],
      'weight': instance.weight,
      'height': instance.height,
      'length': instance.length,
      'width': instance.width,
    };

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'PENDING',
  RequestStatus.approved: 'APPROVED',
  RequestStatus.rejected: 'REJECTED',
  RequestStatus.inTransit: 'IN_TRANSIT',
  RequestStatus.completed: 'COMPLETED',
  RequestStatus.cancelled: 'CANCELLED',
};
