import 'package:json_annotation/json_annotation.dart';

part 'request_dto.g.dart';

/**
 * Data Transfer Object per la creazione e visualizzazione di una richiesta.
 * Gestisce la serializzazione e deserializzazione JSON per l'integrazione API.
 * * @author Roman
 * @version 1.1
 */
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

  /**
   * Crea un'istanza di RequestCreationDTO a partire da una mappa JSON.
   * * @param json Mappa contenente i dati della richiesta.
   * @return Un'istanza della classe mappata.
   */
  factory RequestCreationDTO.fromJson(Map<String, dynamic> json) => _$RequestCreationDTOFromJson(json);

  /**
   * Converte l'istanza corrente in una mappa JSON.
   * * @return Mappa JSON pronta per l'invio via API.
   */
  Map<String, dynamic> toJson() => _$RequestCreationDTOToJson(this);
}

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
}

/**
 * Data Transfer Object per la visualizzazione dettagliata di una richiesta.
 * Include tutti i campi di RequestCreationDTO più informazioni aggiuntive come ID e stato.
 * @author Roman
 * @version 1.0
 */
@JsonSerializable()
class RequestDetailDTO {
  final String? id;
  final String originAddress;
  final String destinationAddress;
  final String pickupDate; // YYYY-MM-DD
  final double weight;
  final double length;
  final double width;
  final double height;
  @JsonKey(name: 'status')
  final RequestStatus? status;

  RequestDetailDTO({
    this.id,
    required this.originAddress,
    required this.destinationAddress,
    required this.pickupDate,
    required this.weight,
    required this.length,
    required this.width,
    required this.height,
    this.status,
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