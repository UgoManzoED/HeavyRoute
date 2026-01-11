class ProposedRouteDTO {
  final String id;
  final String orderId;
  final String plannerName;
  final String origin;
  final String destination;
  final String routeDescription;
  final String loadType;
  final String status;

  // Dati numerici grezzi dal backend
  final double distance; // in Km
  final double duration; // in Minuti

  ProposedRouteDTO({
    required this.id,
    required this.orderId,
    required this.plannerName,
    required this.origin,
    required this.destination,
    required this.routeDescription,
    required this.loadType,
    required this.status,
    required this.distance,
    required this.duration,
  });

  // --- Getter Intelligenti per la UI ---

  /// Formatta i dati tecnici in una stringa leggibile per la card.
  /// Es: "575 km • 6h 30min"
  String get details {
    final int hours = duration ~/ 60;
    final int minutes = (duration % 60).toInt();
    final String timeString = hours > 0 ? "${hours}h ${minutes}min" : "${minutes}min";

    // Arrotonda la distanza a 1 decimale se necessario, o intero
    final String distString = distance.toStringAsFixed(0);

    return "$distString km • $timeString";
  }

  // Helper per sapere se colorare la riga di giallo.
  bool get isPending => status == "WAITING_VALIDATION";

  // Opzionale: Helper per sapere se è stato rifiutato (magari per colorarlo di rosso)
  bool get isRejected => status == "MODIFICATION_REQUESTED";

  // Opzionale: Helper per sapere se è approvato
  bool get isApproved => status == "VALIDATED";

  factory ProposedRouteDTO.fromJson(Map<String, dynamic> json) {
    return ProposedRouteDTO(
      // Gestione sicura dei tipi (String vs Number)
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      plannerName: json['plannerName']?.toString() ?? 'N/D',
      origin: json['origin']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      routeDescription: json['routeDescription']?.toString() ?? '',
      loadType: json['loadType']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',

      // Conversione sicura per i numeri (che potrebbero arrivare come int o double)
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'plannerName': plannerName,
      'origin': origin,
      'destination': destination,
      'routeDescription': routeDescription,
      'loadType': loadType,
      'status': status,
      'distance': distance,
      'duration': duration,
    };
  }
}