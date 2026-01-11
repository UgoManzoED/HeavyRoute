import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../trips/models/trip_model.dart';

class TrafficCoordinatorService {
  final Dio _dio = DioClient.instance;

  // Endpoint: GET /api/traffic-coordinator/routes
  Future<List<TripModel>> getProposedRoutes() async {
    try {
      // Filtriamo per lo stato WAITING_VALIDATION
      final response = await _dio.get('/trips', queryParameters: {'status': 'WAITING_VALIDATION'});

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        // Utilizza il factory TripModel.fromJson
        return data.map((json) => TripModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Errore getProposedRoutes: $e");
      return [];
    }
  }

  /**
   * Approva o Rifiuta il percorso.
   * <p>
   * Corregge l'errore dell'argomento: accetta un [int] per l'ID del viaggio.
   * </p>
   * @param tripId L'ID numerico del viaggio (TripModel.id).
   * @param approved true per approvare, false per richiedere modifiche.
   */
  Future<bool> validateRoute(int tripId, bool approved) async {
    try {
      final String action = approved ? 'approve' : 'reject';
      // L'endpoint usa l'ID intero nel path
      final response = await _dio.patch('/trips/$tripId/route/$action');
      return response.statusCode == 200;
    } catch (e) {
      print("Errore validateRoute: $e");
      return false;
    }
  }
}