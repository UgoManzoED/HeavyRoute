// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransportRequest _$TransportRequestFromJson(
  Map<String, dynamic> json,
) => TransportRequest(
  id: (json['id'] as num).toInt(),
  clientId: (json['clientId'] as num?)?.toInt() ?? 0,
  clientFullName: json['clientFullName'] as String? ?? 'Cliente Sconosciuto',
  originAddress:
      json['originAddress'] as String? ?? 'Indirizzo non specificato',
  destinationAddress:
      json['destinationAddress'] as String? ?? 'Indirizzo non specificato',
  pickupDate: TransportRequest._parseDateSafe(json['pickupDate'] as String?),
  deliveryDate: TransportRequest._parseDateSafeNullable(
    json['deliveryDate'] as String?,
  ),
  requestStatus: $enumDecode(
    _$RequestStatusEnumMap,
    json['requestStatus'],
    unknownValue: RequestStatus.PENDING,
  ),
  load: json['load'] == null
      ? null
      : LoadDetails.fromJson(json['load'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TransportRequestToJson(TransportRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'clientFullName': instance.clientFullName,
      'originAddress': instance.originAddress,
      'destinationAddress': instance.destinationAddress,
      'pickupDate': instance.pickupDate.toIso8601String(),
      'deliveryDate': instance.deliveryDate?.toIso8601String(),
      'requestStatus': _$RequestStatusEnumMap[instance.requestStatus]!,
      'load': instance.load,
    };

const _$RequestStatusEnumMap = {
  RequestStatus.PENDING: 'PENDING',
  RequestStatus.APPROVED: 'APPROVED',
  RequestStatus.PLANNED: 'PLANNED',
  RequestStatus.REJECTED: 'REJECTED',
  RequestStatus.CANCELLED: 'CANCELLED',
  RequestStatus.COMPLETED: 'COMPLETED',
};
