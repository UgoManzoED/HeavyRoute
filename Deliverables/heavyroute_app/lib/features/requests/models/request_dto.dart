import 'package:json_annotation/json_annotation.dart';

part 'request_dto.g.dart';

@JsonSerializable()
class RequestCreationDTO {
  final String originAddress;
  final String destinationAddress;
  final String pickupDate; // YYYY-MM-DD
  final double weight;
  final double length;
  final double width;
  final double height;

  RequestCreationDTO({
    required this.originAddress,
    required this.destinationAddress,
    required this.pickupDate,
    required this.weight,
    required this.length,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() => _$RequestCreationDTOToJson(this);
}