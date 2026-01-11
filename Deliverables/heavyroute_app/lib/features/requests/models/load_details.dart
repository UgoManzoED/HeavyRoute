import 'package:json_annotation/json_annotation.dart';

part 'load_details.g.dart';

@JsonSerializable()
class LoadDetails {
  @JsonKey(name: 'type', defaultValue: 'Generico')
  final String loadType;

  @JsonKey(defaultValue: '')
  final String description;

  @JsonKey(defaultValue: 0.0)
  final double weightKg;

  @JsonKey(name: 'width', defaultValue: 0.0)
  final double widthMeters;

  @JsonKey(name: 'height', defaultValue: 0.0)
  final double heightMeters;

  @JsonKey(name: 'length', defaultValue: 0.0)
  final double lengthMeters;

  LoadDetails({
    required this.loadType,
    required this.description,
    required this.weightKg,
    required this.widthMeters,
    required this.heightMeters,
    required this.lengthMeters,
  });

  factory LoadDetails.fromJson(Map<String, dynamic> json) => _$LoadDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$LoadDetailsToJson(this);
}