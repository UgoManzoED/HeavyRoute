import '../../../requests/models/request_detail_dto.dart';

/**
 * Data Transfer Object per la visualizzazione dei dettagli di un viaggio.
 * <p>
 * Mappa il "Read Model" del backend, includendo i dati arricchiti come
 * i nomi dei driver e i modelli dei veicoli per la visualizzazione in UI.
 * </p>
 * @author Roman
 */
class TripDTO {
  final int id;
  final String tripCode;
  final String status;
  final int? driverId;
  final String? driverName;
  final String? vehiclePlate;
  final String? vehicleModel;
  final RequestDetailDTO request;
  final int? clientId;
  final String? clientFullName;

  TripDTO({
    required this.id,
    required this.tripCode,
    required this.status,
    this.driverId,
    this.driverName,
    this.vehiclePlate,
    this.vehicleModel,
    required this.request,
    this.clientId,
    this.clientFullName,
  });

  /**
   * Crea un'istanza di {@link TripDTO} a partire da una mappa JSON.
   * @param json La mappa contenente i dati dal backend.
   * @return Un oggetto TripDTO formattato.
   */
  factory TripDTO.fromJson(Map<String, dynamic> json) {
    return TripDTO(
      id: json['id'],
      tripCode: json['tripCode'],
      status: json['status'],
      driverId: json['driverId'],
      driverName: json['driverName'],
      vehiclePlate: json['vehiclePlate'],
      vehicleModel: json['vehicleModel'],
      request: RequestDetailDTO.fromJson(json['request']),
      clientId: json['clientId'],
      clientFullName: json['clientFullName'],
    );
  }
}