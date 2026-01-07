import 'package:dio/dio.dart';
import '/core/network/dio_client.dart';
import '../models/request_dto.dart';

class RequestService {
  final Dio _dio = DioClient.instance;

  Future<bool> createRequest(RequestCreationDTO dto) async {
    try {
      final response = await _dio.post(
        '/requests', // Chiama http://.../api/requests
        data: dto.toJson(),
      );

      if (response.statusCode == 200) {
        print("Successo! Risposta server: ${response.data}");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Errore API: ${e.response?.statusCode} - ${e.response?.data}");
      return false;
    } catch (e) {
      print("Errore generico: $e");
      return false;
    }
  }
}