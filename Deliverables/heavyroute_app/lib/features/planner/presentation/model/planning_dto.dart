/**
 * Data Transfer Object per l'operazione di pianificazione risorse.
 * <p>
 * Contiene i dati necessari per assegnare un autista e un veicolo a un
 * viaggio specifico nel database.
 * </p>
 * @author Roman
 */
class PlanningDTO {
  /** L'identificativo tecnico del viaggio. */
  final int tripId;

  /** L'identificativo dell'autista selezionato. */
  final int driverId;

  /** La targa del veicolo assegnato. */
  final String vehiclePlate;

  /**
   * Costruttore standard per {@link PlanningDTO}.
   */
  PlanningDTO({
    required this.tripId,
    required this.driverId,
    required this.vehiclePlate,
  });

  /**
   * Converte l'oggetto in formato JSON per l'invio tramite API.
   * @return Mappa serializzata compatibile con il backend.
   */
  Map<String, dynamic> toJson() => {
    'tripId': tripId,
    'driverId': driverId,
    'vehiclePlate': vehiclePlate,
  };
}