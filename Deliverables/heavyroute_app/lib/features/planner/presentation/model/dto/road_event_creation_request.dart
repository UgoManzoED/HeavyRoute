import 'package:json_annotation/json_annotation.dart';

part 'road_event_creation_request.g.dart';

@JsonSerializable(createFactory: false)
class RoadEventCreationRequest {
  final String type;
  final String severity;
  final String description;
  final double latitude;
  final double longitude;
  final String validFrom;
  final String validTo;

  RoadEventCreationRequest({
    required this.type,
    required this.severity,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.validFrom,
    required this.validTo,
  });

  Map<String, dynamic> toJson() => _$RoadEventCreationRequestToJson(this);
}