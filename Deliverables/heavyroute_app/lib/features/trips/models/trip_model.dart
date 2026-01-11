import 'package:json_annotation/json_annotation.dart';
import '../../../common/models/enums.dart';
import '../../auth/models/user_model.dart';
import '../../requests/models/transport_request.dart';
import '../../resources/models/vehicle_model.dart';
import 'route_model.dart';

part 'trip_model.g.dart';

@JsonSerializable()
class TripModel {
  final int id;
  final String tripCode;

  @JsonKey(unknownEnumValue: TripStatus.IN_PLANNING)
  final TripStatus status;

  // Relazione 1:1 con la richiesta originale
  final TransportRequest request;

  // Dati operativi
  final RouteModel? route;
  final UserModel? driver;
  final VehicleModel? vehicle;

  TripModel({
    required this.id,
    required this.tripCode,
    required this.status,
    required this.request,
    this.route,
    this.driver,
    this.vehicle,
  });

  // --- GETTERS PER LA UI ---

  /// Restituisce il nome completo dell'autista o null se non assegnato
  String? get driverName {
    if (driver == null) return null;
    return "${driver!.firstName} ${driver!.lastName}";
  }

  /// Restituisce la targa del veicolo o null se non assegnato
  String? get vehiclePlate {
    return vehicle?.licensePlate;
  }

  factory TripModel.fromJson(Map<String, dynamic> json) => _$TripModelFromJson(json);
  Map<String, dynamic> toJson() => _$TripModelToJson(this);
}