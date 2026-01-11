import 'package:json_annotation/json_annotation.dart';
import '../../../common/models/enums.dart';
part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  // --- CAMPI COMUNI (BaseEntity + User) ---
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool active;
  final UserRole role;

  // --- CAMPI PERSONALE INTERNO & DRIVER ---
  // Presenti solo se il ruolo è STAFF o DRIVER
  final String? serialNumber; // Matricola
  final DateTime? hireDate;   // Data assunzione

  // --- CAMPI SPECIFICI DRIVER ---
  final String? licenseNumber;

  // Mapping dello stato autista
  @JsonKey(unknownEnumValue: DriverStatus.FREE)
  final DriverStatus? status;

  final bool? free;       // Ridondante (arriva dal JSON)
  final bool? onTheRoad;  // Ridondante (arriva dal JSON)

  // --- CAMPI SPECIFICI CUSTOMER ---
  final String? companyName;
  final String? vatNumber;
  final String? pec;
  final String? address;

  // --- COSTRUTTORE ---
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.active,
    required this.role,
    this.serialNumber,
    this.hireDate,
    this.licenseNumber,
    this.status,
    this.free,
    this.onTheRoad,
    this.companyName,
    this.vatNumber,
    this.pec,
    this.address,
  });

  // --- LOGICA DI UI ---

  // Restituisce "Mario Rossi"
  String get fullName => "$firstName $lastName";

  // Restituisce le iniziali "MR" (utile per gli avatar circolari)
  String get initials => "${firstName[0]}${lastName[0]}".toUpperCase();

  // Helper per sapere rapidamente chi è l'utente
  bool get isDriver => role == UserRole.DRIVER;
  bool get isCustomer => role == UserRole.CUSTOMER;
  bool get isInternal => !isDriver && !isCustomer;

  // --- SERIALIZZAZIONE ---
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}