import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class PlannerService {
  final Dio _dio = DioClient.instance;

  Future<bool> planTripAndSendToCoordinator(int requestId, String routeDescription) async {
    try {
      print("--- TENTATIVO INVIO VIAGGIO ---");

      final payload = {
        'request_id': requestId,
        'route_description': routeDescription,
        'status': 'WAITING_VALIDATION',
      };

      print("Payload inviato: $payload"); // Controlla nella console cosa stai inviando

      final response = await _dio.post('/api/trips', data: payload);

      print("Risposta Server: ${response.statusCode}");

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      // QUESTO È IL PUNTO FONDAMENTALE PER CAPIRE L'ERRORE
      print("Errore Dio: ${e.message}");
      if (e.response != null) {
        print("Status Code: ${e.response?.statusCode}");
        print("Dati Errore Server: ${e.response?.data}");
      }
      return false;
    } catch (e) {
      print("Errore generico: $e");
      return false;
    }
  }
}