/**
 * Data Transfer Object (DTO) per la creazione di una segnalazione stradale.
 * <p>
 * Include i dati geografici e temporali necessari per allertare il motore
 * di navigazione riguardo ostacoli o pericoli sulla rete viaria.
 * </p>
 * @author Roman
 */
class RoadEventCreateDTO {
  /** Tipologia dell'evento (es. OBSTACLE, ACCIDENT). */
  final String type;

  /** Livello di gravità (LOW, MEDIUM, CRITICAL). */
  final String severity;

  /** Descrizione testuale opzionale dell'evento. */
  final String? description;

  /** Latitudine GPS compresa nel range [-90.0, 90.0]. */
  final double latitude;

  /** Longitudine GPS compresa nel range [-180.0, 180.0]. */
  final double longitude;

  /** Data e ora di inizio validità della segnalazione. */
  final DateTime validFrom;

  /** Data e ora di fine validità (se nullo, l'evento è a tempo indeterminato). */
  final DateTime? validTo;

  RoadEventCreateDTO({
    required this.type,
    required this.severity,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.validFrom,
    this.validTo,
  });

  /**
   * Serializza il DTO in JSON gestendo la conversione delle date in formato ISO8601.
   * @return Mappa pronta per l'invio tramite POST.
   */
  Map<String, dynamic> toJson() => {
    'type': type,
    'severity': severity,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'validFrom': validFrom.toIso8601String(),
    'validTo': validTo?.toIso8601String(),
  };

  /**
   * Factory method per la ricostruzione dell'oggetto da dati JSON.
   */
  factory RoadEventCreateDTO.fromJson(Map<String, dynamic> json) {
    return RoadEventCreateDTO(
      type: json['type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      validFrom: DateTime.parse(json['validFrom']),
      validTo: json['validTo'] != null ? DateTime.parse(json['validTo']) : null,
    );
  }
}