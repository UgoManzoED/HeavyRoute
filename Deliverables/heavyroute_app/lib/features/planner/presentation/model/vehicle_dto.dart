/**
 * Data Transfer Object (DTO) per la rappresentazione dei dati tecnici e operativi di un veicolo.
 * <p>
 * Mappa i parametri fisici del mezzo (pesi e dimensioni) utilizzati dal sistema
 * per verificare la compatibilità con le infrastrutture stradali.
 * </p>
 * @author Roman
 */
class VehicleDTO {
  /** Targa univoca del veicolo. */
  final String licensePlate;

  /** Marca e modello del mezzo (es. "Iveco Stralis 500"). */
  final String model;

  /** Portata massima utile espressa in chilogrammi. */
  final double maxLoadCapacity;

  /** Altezza massima del veicolo in metri. */
  final double maxHeight;

  /** Larghezza massima del veicolo in metri. */
  final double maxWidth;

  /** Lunghezza massima del veicolo in metri. */
  final double maxLength;

  /** Stato operativo attuale (es. AVAILABLE, BUSY, MAINTENANCE). */
  final String? status;

  VehicleDTO({
    required this.licensePlate,
    required this.model,
    required this.maxLoadCapacity,
    required this.maxHeight,
    required this.maxWidth,
    required this.maxLength,
    this.status,
  });

  /**
   * Factory method per la creazione di un'istanza da JSON proveniente dal backend.
   * @param json Mappa contenente i dati del veicolo.
   * @return Un'istanza di {@link VehicleDTO}.
   */
  factory VehicleDTO.fromJson(Map<String, dynamic> json) {
    return VehicleDTO(
      licensePlate: json['licensePlate'] as String,
      model: json['model'] as String,
      maxLoadCapacity: (json['maxLoadCapacity'] as num).toDouble(),
      maxHeight: (json['maxHeight'] as num).toDouble(),
      maxWidth: (json['maxWidth'] as num).toDouble(),
      maxLength: (json['maxLength'] as num).toDouble(),
      status: json['status'] as String?,
    );
  }

  /**
   * Converte l'oggetto in formato JSON per l'invio alle API di gestione flotta.
   * @return Mappa serializzata.
   */
  Map<String, dynamic> toJson() => {
    'licensePlate': licensePlate,
    'model': model,
    'maxLoadCapacity': maxLoadCapacity,
    'maxHeight': maxHeight,
    'maxWidth': maxWidth,
    'maxLength': maxLength,
    'status': status,
  };
}