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