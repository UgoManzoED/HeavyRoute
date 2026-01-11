import 'package:json_annotation/json_annotation.dart';

part 'create_request_model.g.dart';

@JsonSerializable(createFactory: false)
class CreateRequestModel {
  @JsonKey(name: 'originAddress')
  final String origin;

  @JsonKey(name: 'destinationAddress')
  final String destination;

  final String pickupDate; // Formato "yyyy-MM-dd"

  final String loadType;
  final double weight;
  final double height;
  final double length;
  final double width;

  CreateRequestModel({
    required this.origin,
    required this.destination,
    required this.pickupDate,
    required this.loadType,
    required this.weight,
    required this.height,
    required this.length,
    required this.width,
  });

  Map<String, dynamic> toJson() => _$CreateRequestModelToJson(this);
}