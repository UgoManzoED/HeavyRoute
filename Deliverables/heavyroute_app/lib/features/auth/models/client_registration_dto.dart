import 'package:json_annotation/json_annotation.dart';

part 'client_registration_dto.g.dart';

@JsonSerializable()
class ClientRegistrationDTO {
  final String username;
  final String password;
  final String email;
  final String companyName;
  final String vatNumber;
  final String address;
  final String pec;
  final String phoneNumber;
  final String firstName;
  final String lastName;

  ClientRegistrationDTO({
    required this.username,
    required this.password,
    required this.email,
    required this.companyName,
    required this.vatNumber,
    required this.address,
    required this.pec,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => _$ClientRegistrationDTOToJson(this);
}