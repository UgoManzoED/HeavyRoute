import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../resources/models/vehicle_model.dart'; // Output
import '../../../resources/models/dto/vehicle_creation_request.dart'; // Input

/**
 * Service responsabile della gestione tecnica e operativa della flotta veicoli.
 */
class VehicleService {
  final Dio _dio = DioClient.instance;

  /**
   * Recupera la lista completa dei veicoli.
   * Endpoint Backend: GET /api/resources/vehicles
   */
  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await _dio.get('/api/resources/vehicles');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => VehicleModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint("🛑 Errore getVehicles: ${e.message}");
      return [];
    }
  }

  /**
   * Registra un nuovo veicolo.
   * Endpoint Backend: POST /api/resources/vehicles
   */
  Future<bool> createVehicle(VehicleCreationRequest request) async {
    try {
      final response = await _dio.post(
          '/api/resources/vehicles',
          data: request.toJson()
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("🛑 Errore createVehicle: ${e.response?.data}");
      return false;
    }
  }
}