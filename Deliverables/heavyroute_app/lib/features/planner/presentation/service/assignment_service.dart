import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../model/trip_dto.dart';
import '../model/planning_dto.dart';

/**
 * Service per la gestione del ciclo di vita dei Viaggi e delle Assegnazioni.
 * <p>
 * Interagisce con il TripController del backend per spostare i viaggi
 * dallo stato IN_PLANNING agli stati operativi successivi.
 * </p>
 * @author Roman
 */
class AssignmentService {
  final Dio _dio = DioClient.instance;

  /**
   * Recupera la lista dei viaggi filtrata per stato (es. IN_PLANNING).
   * @param status Lo stato ricercato.
   * @return Una lista di {@link TripDTO} popolata.
   */
  Future<List<TripDTO>> getTripsByStatus(String status) async {
    try {
      final response = await _dio.get('/trips', queryParameters: {'status': status});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => TripDTO.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("Errore getTrips: ${e.message}");
      return [];
    }
  }

  /**
   * Invia l'assegnazione delle risorse al backend.
   * <p>
   * Corrisponde alla chiamata dell'endpoint di pianificazione.
   * </p>
   * @param dto L'oggetto {@link PlanningDTO} con ID Viaggio, ID Driver e Targa.
   * @return true se il salvataggio nel DB è confermato.
   */
  Future<bool> planTrip(PlanningDTO dto) async {
    try {
      // Nota: tripId è incluso nel body come richiesto dal tuo PlanningDTO Java
      final response = await _dio.post('/trips/${dto.tripId}/plan', data: dto.toJson());
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("Errore planTrip: ${e.response?.data}");
      return false;
    }
  }
}