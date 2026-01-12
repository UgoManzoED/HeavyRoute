import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transport_request.dart';
import '../models/dto/create_request_model.dart';

class RequestService {
  final Dio _dio = DioClient.instance;

  // --- LETTURA ---

  /// Recupera le richieste dell'utente loggato.
  Future<List<TransportRequest>> getMyRequests() async {
    return _fetchRequests('/api/requests/my-requests');
  }

  /// Recupera tutte le richieste (Admin/Planner).
  Future<List<TransportRequest>> getAllRequests() async {
    return _fetchRequests('/api/requests');
  }

  /// Metodo helper privato per evitare codice duplicato
  Future<List<TransportRequest>> _fetchRequests(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {

        if (kDebugMode) {
          debugPrint("📦 JSON RAW ($endpoint): ${response.data}");
        }

        final List<dynamic> data = response.data;

        // Mappatura
        return data.map((json) => TransportRequest.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      _logDioError(endpoint, e);
      return [];
    } catch (e, stackTrace) {
      debugPrint("🛑 ERRORE PARSING ($endpoint): $e");
      debugPrint("📍 StackTrace: $stackTrace");
      return [];
    }
  }

  // --- SCRITTURA ---

  /// Crea una nuova richiesta.
  Future<bool> createRequest(CreateRequestModel dto) async {
    try {
      if (kDebugMode) {
        debugPrint("📤 Invio Payload: ${dto.toJson()}");
      }

      final response = await _dio.post('/api/requests', data: dto.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      _logDioError("createRequest", e);
      return false;
    } catch (e) {
      debugPrint("🛑 Errore Generico createRequest: $e");
      return false;
    }
  }

  /// Elimina una richiesta (solo se PENDING).
  Future<bool> deleteRequest(int requestId) async {
    try {
      final response = await _dio.delete('/api/requests/$requestId');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      _logDioError("deleteRequest", e);
      return false;
    }
  }

  /// Invia richiesta di modifica/annullamento.
  Future<bool> sendModificationRequest(int requestId, String type, String note) async {
    try {
      final response = await _dio.post(
        '/api/requests/$requestId/action-request',
        data: {
          'type': type,
          'note': note,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      _logDioError("sendModificationRequest", e);
      return false;
    }
  }

  void _logDioError(String context, DioException e) {
    debugPrint("🛑 ERRORE HTTP ($context): Status ${e.response?.statusCode}");
    debugPrint("👉 Body: ${e.response?.data}");
  }
}