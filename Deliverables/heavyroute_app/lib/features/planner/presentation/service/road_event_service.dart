import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../model/roadevent_dto.dart';

/**
 * Service per la gestione delle segnalazioni e degli eventi stradali.
 * <p>
 * Consente di inviare dati su incidenti, ostacoli o cantieri per permettere
 * al sistema di ricalcolare i percorsi dei trasporti eccezionali.
 * </p>
 * @author Roman
 */
class RoadEventService {
  /** Istanza del client HTTP con supporto JWT. */
  final Dio _dio = DioClient.instance;

  /**
   * Invia una nuova segnalazione di evento stradale al backend.
   * <p>
   * I dati vengono processati dal motore cartografico per aggiornare
   * in tempo reale la percorribilità delle tratte.
   * </p>
   * @param event Il DTO {@link RoadEventCreateDTO} con coordinate e dettagli.
   * @return true se la segnalazione è stata acquisita dal sistema.
   */
  Future<bool> reportRoadEvent(RoadEventCreateDTO event) async {
    try {
      final response = await _dio.post('/navigation/events', data: event.toJson());
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      _logError("reportRoadEvent", e);
      return false;
    }
  }

  /**
   * Recupera gli eventi attivi in una determinata area o globalmente.
   * @return Lista di eventi stradali attivi.
   */
  Future<List<RoadEventCreateDTO>> getActiveEvents() async {
    try {
      final response = await _dio.get('/navigation/events/active');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => RoadEventCreateDTO.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      _logError("getActiveEvents", e);
      return [];
    }
  }

  /**
   * Helper privato per il logging degli errori di rete.
   */
  void _logError(String method, DioException e) {
    print("--- ERRORE ROAD_EVENT_SERVICE ($method) ---");
    print("Status: ${e.response?.statusCode}");
    print("Dettagli: ${e.response?.data}");
  }
}