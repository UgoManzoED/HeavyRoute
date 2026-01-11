import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../common/models/enums.dart'; // Importa TripStatus
import '../../../trips/models/trip_model.dart'; // Importa il nuovo Model di lettura
import '../../models/dto/assign_trip_request.dart'; // Importa il nuovo DTO di scrittura

/**
 * Service per la gestione del ciclo di vita dei Viaggi e delle Assegnazioni.
 */
class AssignmentService {
  final Dio _dio = DioClient.instance;

  /**
   * Recupera la lista dei viaggi filtrata per stato.
   * Utilizza [TripStatus] enum per garantire la correttezza della query string.
   */
  Future<List<TripModel>> getTripsByStatus(TripStatus status) async {
    try {
      final response = await _dio.get(
          '/trips',
          queryParameters: {'status': status.name}
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => TripModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint("🛑 Errore getTrips: ${e.message}");
      return [];
    } catch (e) {
      debugPrint("🛑 Errore generico getTrips: $e");
      return [];
    }
  }

  /**
   * Invia l'assegnazione delle risorse al backend.
   */
  Future<bool> planTrip(AssignTripRequest request) async {
    try {
      final response = await _dio.post(
          '/trips/${request.tripId}/plan',
          data: request.toJson()
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("🛑 Errore planTrip: ${e.response?.data}");
      return false;
    }
  }
}