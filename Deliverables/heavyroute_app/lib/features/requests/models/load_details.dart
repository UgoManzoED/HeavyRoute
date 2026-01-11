import 'package:json_annotation/json_annotation.dart';

part 'load_details.g.dart';

@JsonSerializable()
class LoadDetails {
  final String? type;     // Es. "Turbina", "Scavatrice"
  final int? quantity;
  
  final double? weightKg;

  final double? height;
  final double? width;
  final double? length;

  LoadDetails({
    this.type,
    this.quantity,
    this.weightKg,
    this.height,
    this.width,
    this.length,
  });

  factory LoadDetails.fromJson(Map<String, dynamic> json) => _$LoadDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$LoadDetailsToJson(this);
}