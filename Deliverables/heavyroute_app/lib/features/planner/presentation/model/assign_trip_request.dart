import 'package:json_annotation/json_annotation.dart';

part 'assign_trip_request.g.dart';

@JsonSerializable(createFactory: false)
class AssignTripRequest {
  final int tripId;
  final int driverId;
  final String vehiclePlate;

  AssignTripRequest({
    required this.tripId,
    required this.driverId,
    required this.vehiclePlate,
  });

  Map<String, dynamic> toJson() => _$AssignTripRequestToJson(this);
}