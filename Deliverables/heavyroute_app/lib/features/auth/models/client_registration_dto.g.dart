// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_registration_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientRegistrationDTO _$ClientRegistrationDTOFromJson(
  Map<String, dynamic> json,
) => ClientRegistrationDTO(
  username: json['username'] as String,
  password: json['password'] as String,
  email: json['email'] as String,
  companyName: json['companyName'] as String,
  vatNumber: json['vatNumber'] as String,
  address: json['address'] as String,
  pec: json['pec'] as String,
  phoneNumber: json['phoneNumber'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
);

Map<String, dynamic> _$ClientRegistrationDTOToJson(
  ClientRegistrationDTO instance,
) => <String, dynamic>{
  'username': instance.username,
  'password': instance.password,
  'email': instance.email,
  'companyName': instance.companyName,
  'vatNumber': instance.vatNumber,
  'address': instance.address,
  'pec': instance.pec,
  'phoneNumber': instance.phoneNumber,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
};
