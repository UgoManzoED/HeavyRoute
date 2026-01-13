import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // IMPORTANTE
import '../../../../core/network/dio_client.dart';
import '../../trips/models/trip_model.dart';

class DriverTripService {
  final Dio _dio = DioClient.instance;

  // Rimuoviamo la variabile fissa: final int _currentDriverId = 5;

  /**
   * Recupera l'ID dell'autista loggato dalla memoria locale.
   */
  Future<int?> _getStoredDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<List<TripModel>> getMyTrips() async {
    try {
      // 1. Recupera l'ID dinamico
      final driverId = await _getStoredDriverId();

      // Se non c'è ID (es. login scaduto o errore), ritorna lista vuota o gestisci errore
      if (driverId == null) {
        debugPrint("🛑 ERRORE: Nessun Driver ID trovato nelle preferenze.");
        return [];
      }

      debugPrint("📡 Recupero viaggi per Driver ID: $driverId");

      // 2. Usa l'ID nella chiamata
      final response = await _dio.get('/api/trips/driver/$driverId');

      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List)
            .map((json) => TripModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("🛑 Errore getMyTrips: $e");
      return [];
    }
  }

  Future<bool> updateTripStatus(int tripId, String newStatus) async {
    try {
      // Nota: Per l'update non serve l'ID driver, basta l'ID viaggio
      final response = await _dio.patch(
        '/api/trips/$tripId/status',
        data: newStatus,
        options: Options(contentType: Headers.textPlainContentType),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("🛑 Errore updateTripStatus: $e");
      return false;
    }
  }
}