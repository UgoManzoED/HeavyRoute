import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class FleetService {
  final Dio _dio = DioClient.instance;

  // Usa l'endpoint esistente che restituisce tutti i viaggi
  // Il backend restituisce List<TripResponseDTO>
  Future<List<dynamic>> getFleetStatus() async {
    try {
      final response = await _dio.get('/api/trips');
      return response.data; // Ritorna la lista grezza, la mapperemo nella UI
    } catch (e) {
      return [];
    }
  }
}