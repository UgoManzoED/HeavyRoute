import 'package:json_annotation/json_annotation.dart';

part 'request_detail_dto.g.dart';

/**
 * Enum per lo stato della richiesta.
 * @author Roman
 * @version 1.0
 */
enum RequestStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('IN_TRANSIT')
  inTransit,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
}

@JsonSerializable()
class RequestDetailDTO {
  final int? clientId;
  final String? clientFullName;

  final int id;
  final String originAddress;
  final String destinationAddress;

  // Spring invia LocalDate come stringa "YYYY-MM-DD"
  final String pickupDate;

  @JsonKey(name: 'status', unknownEnumValue: RequestStatus.pending)
  final RequestStatus? status;

  final double weight;
  final double height;
  final double length;
  final double width;

  RequestDetailDTO({
    this.clientId,
    this.clientFullName,
    required this.id,
    required this.originAddress,
    required this.destinationAddress,
    required this.pickupDate,
    required this.status,
    required this.weight,
    required this.height,
    required this.length,
    required this.width,
  });

  /**
   * Crea un'istanza di RequestDetailDTO a partire da una mappa JSON.
   * @param json Mappa contenente i dati della richiesta.
   * @return Un'istanza della classe mappata.
   */
  factory RequestDetailDTO.fromJson(Map<String, dynamic> json) => _$RequestDetailDTOFromJson(json);

  /**
   * Converte l'istanza corrente in una mappa JSON.
   * @return Mappa JSON pronta per l'invio via API.
   */
  Map<String, dynamic> toJson() => _$RequestDetailDTOToJson(this);
}