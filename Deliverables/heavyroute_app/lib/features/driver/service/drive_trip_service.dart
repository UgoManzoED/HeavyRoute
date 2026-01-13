import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../trips/models/trip_model.dart';

/// Service per la gestione delle operazioni di viaggio lato Autista.
class DriverTripService {
  final Dio _dio = DioClient.instance;

  /**
   * Mappa delle transizioni di stato consentite.
   * <p>
   * Chiave: Stato Attuale.
   * Valore: Lista degli stati futuri possibili.
   * </p>
   */
  // MODIFICA: Tolto l'underscore (_) per renderla accessibile da fuori
  static const Map<String, List<String>> allowedTransitions = {
    'CONFIRMED': ['ACCEPTED'],
    'ACCEPTED': ['IN_TRANSIT'],
    'IN_TRANSIT': ['PAUSED', 'DELIVERING', 'COMPLETED'],
    'PAUSED': ['IN_TRANSIT', 'DELIVERING', 'COMPLETED'],
    'DELIVERING': ['COMPLETED', 'IN_TRANSIT'],
    'COMPLETED': [],
    'CANCELLED': [],
  };

  /**
   * Recupera l'ID dell'autista loggato dalla memoria locale.
   * * @return L'ID utente salvato nelle SharedPreferences o null se non presente.
   */
  Future<int?> _getStoredDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  /**
   * Verifica se il cambio di stato richiesto è logicamente valido.
   * <p>
   * Impedisce regressioni inconsistenti (es. da COMPLETED a ACCEPTED).
   * </p>
   * * @param current Lo stato attuale del viaggio.
   * @param next Il nuovo stato proposto.
   * @return true se la transizione è permessa, false altrimenti.
   */
  bool _isValidTransition(String current, String next) {
    // Se lo stato attuale non è mappato (es. stato sconosciuto), blocchiamo per sicurezza
    if (!allowedTransitions.containsKey(current)) {
      debugPrint("⚠️ Stato sconosciuto '$current'. Transizione bloccata.");
      return false;
    }

    final allowed = allowedTransitions[current];

    // Se la lista è vuota (stato terminale) o non contiene il next status
    if (allowed == null || !allowed.contains(next)) {
      debugPrint("🚫 Transizione Illegale: $current -> $next");
      return false;
    }

    return true;
  }

  /**
   * Recupera la lista dei viaggi assegnati all'autista loggato.
   * * @return Lista di {@link TripModel} o lista vuota in caso di errore.
   */
  Future<List<TripModel>> getMyTrips() async {
    try {
      final driverId = await _getStoredDriverId();

      if (driverId == null) {
        debugPrint("🛑 ERRORE: Nessun Driver ID trovato nelle preferenze.");
        return [];
      }

      debugPrint("📡 Recupero viaggi per Driver ID: $driverId");

      final response = await _dio.get('/api/trips/driver/$driverId');

      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List)
            .map((json) => TripModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("🛑 Errore getMyTrips: $e");
      return [];
    }
  }

  /**
   * Aggiorna lo stato di un viaggio specifico.
   * <p>
   * Esegue una validazione locale prima di inviare la richiesta al server.
   * </p>
   * * @param tripId ID univoco del viaggio.
   * @param currentStatus Lo stato ATTUALE del viaggio (necessario per il controllo di consistenza).
   * @param newStatus Il NUOVO stato da applicare.
   * @return true se l'aggiornamento ha successo, false se bloccato o errore server.
   */
  Future<bool> updateTripStatus(int tripId, String currentStatus, String newStatus) async {
    // 1. Validazione Locale di Consistenza
    if (!_isValidTransition(currentStatus, newStatus)) {
      // Ritorniamo false subito, risparmiando una chiamata di rete inutile
      return false;
    }

    try {
      debugPrint("📡 Invio aggiornamento stato: $newStatus per Trip $tripId (da $currentStatus)");

      final response = await _dio.patch(
        '/api/trips/$tripId/status',
        data: newStatus,
        options: Options(
          contentType: Headers.textPlainContentType,
        ),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Stato aggiornato con successo!");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("🛑 Errore updateTripStatus: $e");
      return false;
    }
  }
}