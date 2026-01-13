import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../../trips/models/trip_model.dart';

class TrafficCoordinatorService {
  final Dio _dio = DioClient.instance;

  /// Recupera i viaggi filtrati per stato (es. "WAITING_VALIDATION")
  /// Sostituisce il vecchio 'getProposedRoutes' per essere più flessibile
  Future<List<TripModel>> getTripsByStatus(String status) async {
    const String endpoint = '/api/trips';

    try {
      // Passiamo lo status come parametro query
      final response = await _dio.get(
          endpoint,
          queryParameters: {'status': status}
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;

        debugPrint("📡 [CoordinatorService] Scaricati ${data.length} viaggi con stato $status");

        return data.map((json) => TripModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("🛑 [CoordinatorService] Errore getTripsByStatus: $e");
      return [];
    }
  }

  Future<List<TripModel>> getTripsByStatuses(List<String> statuses) async {
    const String endpoint = '/api/trips';

    try {
      debugPrint("📡 Richiedo stati: $statuses");
      final String queryParams = statuses.map((s) => "status=$s").join("&");

      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'status': statuses.join(',')
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        debugPrint("✅ Trovati ${data.length} viaggi.");
        return data.map((json) => TripModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        debugPrint("🛑 ERRORE API (${e.response?.statusCode}): ${e.response?.data}");
      } else {
        debugPrint("🛑 ERRORE GENERICO: $e");
      }
      return [];
    }
  }

  /// Approva o Rifiuta il percorso inviando il payload corretto al backend
  Future<bool> validateRoute(int tripId, bool approved, {String feedback = ""}) async {
    try {
      // L'endpoint nel backend è unico: /approve
      final String endpoint = '/api/trips/$tripId/route/approve';

      debugPrint("📡 [CoordinatorService] Invio validazione: Trip $tripId -> Approved: $approved");

      final response = await _dio.post(
        endpoint,
        data: {
          "approved": approved,
          "feedback": feedback
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("🛑 [CoordinatorService] Errore validateRoute: $e");
      return false;
    }
  }
}