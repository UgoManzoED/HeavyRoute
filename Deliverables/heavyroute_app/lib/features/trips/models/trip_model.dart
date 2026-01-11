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
  final String tripCode; // Es. "TRP-2026-X8Y9"

  @JsonKey(unknownEnumValue: TripStatus.IN_PLANNING)
  final TripStatus status;

  // Relazione 1:1 con la richiesta originale
  final TransportRequest request;

  // Dati operativi (possono essere null se il viaggio è appena stato creato)
  final RouteModel? route;
  final UserModel? driver;   // L'autista assegnato
  final VehicleModel? vehicle; // Il mezzo assegnato

  TripModel({
    required this.id,
    required this.tripCode,
    required this.status,
    required this.request,
    this.route,
    this.driver,
    this.vehicle,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) => _$TripModelFromJson(json);
  Map<String, dynamic> toJson() => _$TripModelToJson(this);
}