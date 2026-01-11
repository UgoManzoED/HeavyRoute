import 'package:json_annotation/json_annotation.dart';
import '../../../common/models/enums.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel {
  final int id;
  final String licensePlate;
  final String model;

  @JsonKey(name: 'maxLoadCapacity')
  final double capacity; // Mapping per brevità

  final double maxHeight;
  final double maxWidth;
  final double maxLength;

  @JsonKey(defaultValue: VehicleStatus.AVAILABLE)
  final VehicleStatus status;

  final bool available;
  final bool inMaintenance;

  VehicleModel({
    required this.id,
    required this.licensePlate,
    required this.model,
    required this.capacity,
    required this.maxHeight,
    required this.maxWidth,
    required this.maxLength,
    required this.status,
    required this.available,
    required this.inMaintenance,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => _$VehicleModelFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);
}