import 'package:json_annotation/json_annotation.dart';

part 'road_event_model.g.dart';

@JsonSerializable()
class RoadEventModel {
  final int id;
  final String type;
  final String severity;
  final String description;
  final double latitude;
  final double longitude;
  final bool active;
  final bool blocking;
  final String validFrom;
  final String validTo;

  RoadEventModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.active,
    required this.blocking,
    required this.validFrom,
    required this.validTo,
  });

  factory RoadEventModel.fromJson(Map<String, dynamic> json) => _$RoadEventModelFromJson(json);
}