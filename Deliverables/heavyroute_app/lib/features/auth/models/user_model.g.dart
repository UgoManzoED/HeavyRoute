// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  active: json['active'] as bool,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  serialNumber: json['serialNumber'] as String?,
  hireDate: json['hireDate'] == null
      ? null
      : DateTime.parse(json['hireDate'] as String),
  licenseNumber: json['licenseNumber'] as String?,
  status: $enumDecodeNullable(
    _$DriverStatusEnumMap,
    json['status'],
    unknownValue: DriverStatus.FREE,
  ),
  free: json['free'] as bool?,
  onTheRoad: json['onTheRoad'] as bool?,
  companyName: json['companyName'] as String?,
  vatNumber: json['vatNumber'] as String?,
  pec: json['pec'] as String?,
  address: json['address'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'active': instance.active,
  'role': _$UserRoleEnumMap[instance.role]!,
  'serialNumber': instance.serialNumber,
  'hireDate': instance.hireDate?.toIso8601String(),
  'licenseNumber': instance.licenseNumber,
  'status': _$DriverStatusEnumMap[instance.status],
  'free': instance.free,
  'onTheRoad': instance.onTheRoad,
  'companyName': instance.companyName,
  'vatNumber': instance.vatNumber,
  'pec': instance.pec,
  'address': instance.address,
};

const _$UserRoleEnumMap = {
  UserRole.CUSTOMER: 'CUSTOMER',
  UserRole.LOGISTIC_PLANNER: 'LOGISTIC_PLANNER',
  UserRole.TRAFFIC_COORDINATOR: 'TRAFFIC_COORDINATOR',
  UserRole.DRIVER: 'DRIVER',
  UserRole.ACCOUNT_MANAGER: 'ACCOUNT_MANAGER',
};

const _$DriverStatusEnumMap = {
  DriverStatus.FREE: 'FREE',
  DriverStatus.ASSIGNED: 'ASSIGNED',
  DriverStatus.ON_THE_ROAD: 'ON_THE_ROAD',
  DriverStatus.RESTING: 'RESTING',
};
