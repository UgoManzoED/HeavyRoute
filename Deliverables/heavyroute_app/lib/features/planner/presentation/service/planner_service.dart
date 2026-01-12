import 'dart:developer'; // Per i log professionali
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../trips/models/trip_model.dart';

class PlannerService {
  final Dio _dio = DioClient.instance;

  /// Approva la richiesta e restituisce il Viaggio completo (con rotta Mapbox)
  Future<TripModel?> approveRequestAndGetTrip(int requestId) async {
    try {
      log("📡 [PlannerService] Tentativo approvazione richiesta #$requestId");

      final response = await _dio.post(
        '/api/trips/$requestId/approve',
        data: {},
      );

      log("✅ [PlannerService] Risposta Server: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TripModel.fromJson(response.data);
      }

      return null;

    } on DioException catch (e) {
      // Gestione avanzata degli errori (es. 409 da Mapbox o 404)
      String errorMessage = "Errore di connessione al server.";

      if (e.response != null) {
        log("🔥 [PlannerService] Errore Backend (${e.response?.statusCode}): ${e.response?.data}");

        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['detail'] ?? data['message'] ?? data['error'] ?? errorMessage;
        }
      } else {
        log("🔥 [PlannerService] Errore Dio: ${e.message}");
      }

      // Rilanciamo l'errore pulito così il Dialog può mostrarlo nella SnackBar
      throw Exception(errorMessage);

    } catch (e) {
      log("🔥 [PlannerService] Errore generico: $e");
      throw Exception("Si è verificato un errore imprevisto.");
    }
  }
}