import 'package:json_annotation/json_annotation.dart';
import '../../../common/models/enums.dart';
import '../../requests/models/transport_request.dart';
import 'route_model.dart';

part 'trip_model.g.dart';

@JsonSerializable()
class TripModel {
  final int id;

  @JsonKey(defaultValue: "N/D")
  final String tripCode;

  @JsonKey(unknownEnumValue: TripStatus.IN_PLANNING)
  final TripStatus status;

  // --- RELAZIONI ---

  // Il backend manda 'request' completa
  final TransportRequest request;

  // Il backend manda 'route' (può essere null)
  final RouteModel? route;

  // --- DATI PIATTI ---
  final int? driverId;
  final String? driverName;
  final String? vehiclePlate;
  final String? vehicleModel;

  TripModel({
    required this.id,
    required this.tripCode,
    required this.status,
    required this.request,
    this.route,
    this.driverId,
    this.driverName,
    this.vehiclePlate,
    this.vehicleModel,
  });

  // --- GETTERS PER LA UI ---

  String get formattedDriverName => driverName ?? "Non Assegnato";
  String get formattedVehicle => vehiclePlate != null ? "$vehicleModel ($vehiclePlate)" : "Non Assegnato";

  factory TripModel.fromJson(Map<String, dynamic> json) => _$TripModelFromJson(json);
  Map<String, dynamic> toJson() => _$TripModelToJson(this);
}