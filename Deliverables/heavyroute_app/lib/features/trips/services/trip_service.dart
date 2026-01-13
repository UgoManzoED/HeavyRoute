import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/trip_model.dart';

/// Service Layer per il Planner.
/// <p>
/// Gestisce la comunicazione con il Backend per:
/// 1. Calcolare le rotte (via endpoint /approve)
/// 2. Recuperare risorse (autisti/veicoli)
/// 3. Confermare la pianificazione
/// </p>
class TripService {
  // Usiamo l'istanza Singleton configurata con i Logger
  final Dio _dio = DioClient.instance;

  /// 1. AZIONE PRINCIPALE: Approva Richiesta & Calcola Rotta
  /// <p>
  /// Chiama il backend che:
  /// - Verifica l'idempotenza (se il viaggio esiste, lo restituisce)
  /// - Chiama Mapbox (Server-side)
  /// - Salva la rotta nel DB
  /// - Restituisce il TripModel completo di Polyline e Coordinate
  /// </p>
  Future<TripModel?> approveRequestAndGetTrip(int requestId) async {
    final String endpoint = '/api/trips/$requestId/approve';

    try {
      debugPrint("🚀 [PlannerService] Richiedo calcolo rotta per Request #$requestId...");

      final response = await _dio.post(endpoint);

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        debugPrint("✅ [PlannerService] Rotta ricevuta dal Backend!");
        // Parsing del JSON in Modello
        return TripModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      // L'errore dettagliato è già stampato dal DioClient
      debugPrint("🛑 [PlannerService] Errore critico nel calcolo rotta.");
      rethrow; // Rilanciamo per mostrare la snackbar rossa nel Dialog
    }
  }

  /// 2. Recupera tutti i viaggi (Per la Dashboard)
  Future<List<TripModel>> getAllTrips() async {
    const String endpoint = '/api/trips';
    try {
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => TripModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("🛑 Errore getAllTrips: $e");
      return [];
    }
  }

  /// 3. Recupera solo i viaggi da pianificare
  Future<List<TripModel>> getTripsToPlan() async {
    const String endpoint = '/api/trips/planning';

    try {
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => TripModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("🛑 [PlannerService] Errore getTripsToPlan: $e");
      return [];
    }
  }

  /// 4. Recupera Autisti Liberi
  Future<List<dynamic>> getAvailableDrivers() async {
    try {
      final response = await _dio.get('/api/resources/drivers/available');
      return response.data ?? [];
    } catch (e) {
      debugPrint("🛑 Errore getAvailableDrivers: $e");
      return [];
    }
  }

  /// 5. Recupera Veicoli Disponibili
  Future<List<dynamic>> getAvailableVehicles() async {
    try {
      final response = await _dio.get('/api/resources/vehicles/available');
      return response.data ?? [];
    } catch (e) {
      debugPrint("🛑 Errore getAvailableVehicles: $e");
      return [];
    }
  }

  /// 6. Assegna Risorse (Conferma Finale)
  Future<bool> assignResources(int tripId, int driverId, String vehiclePlate) async {
    final String endpoint = '/api/trips/$tripId/plan';
    try {
      debugPrint("📝 [PlannerService] Assegnazione risorse...");
      final response = await _dio.put(
        endpoint,
        data: {
          'driverId': driverId,
          'vehiclePlate': vehiclePlate,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("🛑 Errore assignResources: $e");
      return false;
    }
  }
}