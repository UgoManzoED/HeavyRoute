import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../models/trip_model.dart';

class TripService {
  final Dio _dio = DioClient.instance;

  // --- METODI ESISTENTI (getAllTrips, approveRequest...) ---

  /// Recupera solo i viaggi che sono nello stato IN_PLANNING
  /// Endpoint: GET /api/trips/planning
  Future<List<TripModel>> getTripsToPlan() async {
    try {
      final response = await _dio.get('/api/trips/planning');
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).map((json) => TripModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Errore getTripsToPlan: $e");
      return [];
    }
  }

  /// Recupera gli autisti LIBERI (Status: FREE)
  /// Endpoint: GET /api/resources/drivers/available
  Future<List<dynamic>> getAvailableDrivers() async {
    try {
      final response = await _dio.get('/api/resources/drivers/available');
      return response.data ?? [];
    } catch (e) {
      debugPrint("Errore getAvailableDrivers: $e");
      return [];
    }
  }

  /// Recupera i veicoli DISPONIBILI (Status: AVAILABLE)
  /// Endpoint: GET /api/resources/vehicles/available
  Future<List<dynamic>> getAvailableVehicles() async {
    try {
      final response = await _dio.get('/api/resources/vehicles/available');
      return response.data ?? [];
    } catch (e) {
      debugPrint("Errore getAvailableVehicles: $e");
      return [];
    }
  }

  /// Assegna Autista e Veicolo al viaggio
  /// Endpoint: PUT /api/trips/{id}/plan
  Future<bool> assignResources(int tripId, int driverId, String vehiclePlate) async {
    try {
      final response = await _dio.put(
        '/api/trips/$tripId/plan',
        data: {
          'driverId': driverId,
          'vehiclePlate': vehiclePlate,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Errore assignResources: $e");
      return false;
    }
  }
}