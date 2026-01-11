import 'package:json_annotation/json_annotation.dart';
import '../../../../common/models/enums.dart';

part 'vehicle_creation_request.g.dart';

@JsonSerializable(createFactory: false)
class VehicleCreationRequest {
  final String licensePlate;
  final String model;
  final double maxLoadCapacity;
  final double maxHeight;
  final double maxWidth;
  final double maxLength;

  @JsonKey(unknownEnumValue: VehicleStatus.AVAILABLE)
  final VehicleStatus status;

  VehicleCreationRequest({
    required this.licensePlate,
    required this.model,
    required this.maxLoadCapacity,
    required this.maxHeight,
    required this.maxWidth,
    required this.maxLength,
    required this.status,
  });

  Map<String, dynamic> toJson() => _$VehicleCreationRequestToJson(this);
}