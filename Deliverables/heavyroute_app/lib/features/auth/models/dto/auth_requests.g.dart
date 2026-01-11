// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

Map<String, dynamic> _$CustomerRegistrationRequestToJson(
  CustomerRegistrationRequest instance,
) => <String, dynamic>{
  'username': instance.username,
  'password': instance.password,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'companyName': instance.companyName,
  'vatNumber': instance.vatNumber,
  'pec': instance.pec,
  'address': instance.address,
};
