import 'package:json_annotation/json_annotation.dart';

part 'create_request_model.g.dart';

@JsonSerializable(createFactory: false)
class CreateRequestModel {

  final String originAddress;
  final String destinationAddress;
  final String pickupDate;

  @JsonKey(name: 'loadType')
  final String loadType;

  final String description;

  @JsonKey(name: 'weight')
  final double weight;

  @JsonKey(name: 'width')
  final double width;

  @JsonKey(name: 'height')
  final double height;

  @JsonKey(name: 'length')
  final double length;

  CreateRequestModel({
    required this.originAddress,
    required this.destinationAddress,
    required this.pickupDate,
    required this.loadType,
    required this.description,
    required this.weight,
    required this.width,
    required this.height,
    required this.length,
  });

  Map<String, dynamic> toJson() => _$CreateRequestModelToJson(this);
}