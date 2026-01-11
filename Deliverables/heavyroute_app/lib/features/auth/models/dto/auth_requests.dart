import 'package:json_annotation/json_annotation.dart';

part 'auth_requests.g.dart';

@JsonSerializable(createFactory: false)
class LoginRequest {
  final String username;
  final String password;
  LoginRequest({required this.username, required this.password});
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class CustomerRegistrationRequest {
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String companyName;
  final String vatNumber;
  final String pec;
  final String address;

  CustomerRegistrationRequest({
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.companyName,
    required this.vatNumber,
    required this.pec,
    required this.address,
  });
  Map<String, dynamic> toJson() => _$CustomerRegistrationRequestToJson(this);
}