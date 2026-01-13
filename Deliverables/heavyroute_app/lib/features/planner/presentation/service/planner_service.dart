import 'package:flutter/foundation.dart'; // Serve per debugPrint
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../trips/models/trip_model.dart';

class PlannerService {
  final Dio _dio = DioClient.instance;

  /// 1. Approva la richiesta e restituisce il Viaggio completo (con rotta Mapbox)
  Future<TripModel?> approveRequestAndGetTrip(int requestId) async {
    try {
      debugPrint("📡 [PlannerService] Tentativo approvazione richiesta #$requestId");

      final response = await _dio.post(
        '/api/trips/$requestId/approve',
        data: {},
      );

      debugPrint("✅ [PlannerService] Risposta Server: ${response.statusCode}");

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return TripModel.fromJson(response.data);
      }

      return null;

    } on DioException catch (e) {
      String errorMessage = "Errore di connessione al server.";

      if (e.response != null) {
        debugPrint("❌ [PlannerService] Errore Backend (${e.response?.statusCode}): ${e.response?.data}");
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['detail'] ?? data['message'] ?? data['error'] ?? errorMessage;
        }
      } else {
        debugPrint("❌ [PlannerService] Errore Dio: ${e.message}");
      }
      throw Exception(errorMessage);

    } catch (e) {
      debugPrint("❌ [PlannerService] Errore generico: $e");
      throw Exception("Si è verificato un errore imprevisto.");
    }
  }

  /// 2. Recupera Autisti Liberi
  Future<List<dynamic>> getAvailableDrivers() async {
    try {
      debugPrint("📡 [PlannerService] Recupero autisti disponibili...");
      final response = await _dio.get('/api/resources/drivers/available');
      return response.data ?? [];
    } catch (e) {
      debugPrint("❌ [PlannerService] Errore getAvailableDrivers: $e");
      return [];
    }
  }

  /// 3. Recupera Veicoli Disponibili
  Future<List<dynamic>> getAvailableVehicles() async {
    try {
      debugPrint("📡 [PlannerService] Recupero veicoli disponibili...");
      final response = await _dio.get('/api/resources/vehicles/available');
      return response.data ?? [];
    } catch (e) {
      debugPrint("❌ [PlannerService] Errore getAvailableVehicles: $e");
      return [];
    }
  }

  /// 4. Assegna Risorse (Conferma Finale)
  Future<bool> assignResources(int tripId, int driverId, String vehiclePlate) async {
    final String endpoint = '/api/trips/$tripId/plan';
    try {
      debugPrint("📡 [PlannerService] Assegnazione risorse: Trip $tripId -> Driver $driverId, Truck $vehiclePlate");

      final response = await _dio.put(
        endpoint,
        data: {
          'driverId': driverId,
          'vehiclePlate': vehiclePlate,
        },
      );

      if (response.statusCode == 200) {
        debugPrint("✅ [PlannerService] Risorse assegnate con successo!");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ [PlannerService] Errore assignResources: $e");
      throw Exception("Impossibile assegnare le risorse: ${e.toString()}");
    }
  }
}