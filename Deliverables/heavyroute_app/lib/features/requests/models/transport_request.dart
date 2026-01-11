import 'package:json_annotation/json_annotation.dart';
import '../../../common/models/enums.dart';
import 'load_details.dart';

part 'transport_request.g.dart';

@JsonSerializable()
class TransportRequest {
  final int id;

  @JsonKey(defaultValue: 0)
  final int clientId;

  @JsonKey(defaultValue: "Cliente Sconosciuto")
  final String clientFullName;

  @JsonKey(defaultValue: "Indirizzo non specificato")
  final String originAddress;

  @JsonKey(defaultValue: "Indirizzo non specificato")
  final String destinationAddress;

  @JsonKey(fromJson: _parseDateSafe)
  final DateTime pickupDate;

  @JsonKey(fromJson: _parseDateSafeNullable)
  final DateTime? deliveryDate;

  @JsonKey(unknownEnumValue: RequestStatus.PENDING)
  final RequestStatus requestStatus;

  final LoadDetails? load;

  TransportRequest({
    required this.id,
    required this.clientId,
    required this.clientFullName,
    required this.originAddress,
    required this.destinationAddress,
    required this.pickupDate,
    this.deliveryDate,
    required this.requestStatus,
    this.load,
  });

  // Getter
  String get customerName => clientFullName;
  String get origin => originAddress;
  String get destination => destinationAddress;

  // --- HELPER DATE ---
  static DateTime _parseDateSafe(String? dateStr) {
    if (dateStr == null) return DateTime.now(); // Fallback
    return DateTime.parse(dateStr);
  }

  static DateTime? _parseDateSafeNullable(String? dateStr) {
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }

  // Getter per la UI
  String get formattedId {
    return "HR-${id.toString().padLeft(6, '0')}";
  }

  factory TransportRequest.fromJson(Map<String, dynamic> json) => _$TransportRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TransportRequestToJson(this);
}