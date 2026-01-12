import 'package:dio/dio.dart';
import 'dart:developer' as developer; // Aggiungi questo per i log
import '../../../../core/network/dio_client.dart';
import '../../trips/models/trip_model.dart';

class TrafficCoordinatorService {
  final Dio _dio = DioClient.instance;

  // Endpoint: GET /api/trips
  Future<List<TripModel>> getProposedRoutes() async {
    const String endpoint = '/api/trips';

    try {
      final response = await _dio.get(endpoint, queryParameters: {'status': 'WAITING_VALIDATION'});

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;

        developer.log("Rotta scaricata: ${data.length} elementi", name: "CoordinatorService");

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
   */
  Future<bool> validateRoute(int tripId, bool approved) async {
    try {
      // Se approved è true -> azione = 'approve'
      // Se approved è false -> azione = 'reject'
      final String action = approved ? 'approve' : 'reject';

      final String endpoint = '/api/trips/$tripId/route/$action';
      developer.log("Tentativo validazione: $endpoint", name: "CoordinatorService");

      final response = await _dio.post(endpoint);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Errore validateRoute: $e");
      return false;
    }
  }
}