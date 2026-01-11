import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../model/dto/road_event_creation_request.dart';
import '../model/road_event_model.dart';

class RoadEventService {
  final Dio _dio = DioClient.instance;

  /**
   * Invia una nuova segnalazione (Input: Request).
   * URL Backend corretto: /resources/events
   */
  Future<bool> reportRoadEvent(RoadEventCreationRequest request) async {
    try {
      final response = await _dio.post(
          '/resources/events',
          data: request.toJson()
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("🛑 Errore reportRoadEvent: ${e.response?.statusCode} - ${e.response?.data}");
      return false;
    }
  }

  /**
   * Recupera gli eventi attivi (Output: List<Model>).
   * URL Backend corretto: /resources/events/active
   */
  Future<List<RoadEventModel>> getActiveEvents() async {
    try {
      final response = await _dio.get('/resources/events/active');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => RoadEventModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint("🛑 Errore getActiveEvents: ${e.message}");
      return [];
    }
  }
}