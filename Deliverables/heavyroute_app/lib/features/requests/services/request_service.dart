import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/create_request_model.dart'; // O request_create_dto.dart a seconda del file
import '../models/transport_request.dart'; // <--- IMPORT AGGIORNATO

/**
 * Service Layer per la gestione delle Richieste di Trasporto.
 * <p>
 * Utilizza il modello di dominio {@link TransportRequest} per la comunicazione
 * con il backend.
 * </p>
 * @author Roman
 */
class RequestService {
  final Dio _dio = DioClient.instance;

  /**
   * Recupera la lista delle richieste dell'utente loggato.
   * @return Lista di {@link TransportRequest}.
   */
  Future<List<TransportRequest>> getMyRequests() async {
    try {
      final response = await _dio.get('/requests/my-requests');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        // Utilizza il factory TransportRequest.fromJson
        return data.map((json) => TransportRequest.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      _logDioError("getMyRequests", e);
      return [];
    } catch (e) {
      print("Errore generico (getMyRequests): $e");
      return [];
    }
  }

  /**
   * Crea una nuova richiesta.
   * (Nota: Qui si usa ancora il DTO di creazione, diverso dal modello di risposta)
   */
  Future<bool> createRequest(CreateRequestModel dto) async {
    try {
      final response = await _dio.post('/requests', data: dto.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      _logDioError("createRequest", e);
      return false;
    } catch (e) {
      return false;
    }
  }

  /**
   * Elimina una richiesta (solo se PENDING).
   */
  Future<bool> deleteRequest(int requestId) async {
    try {
      final response = await _dio.delete('/requests/$requestId');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      _logDioError("deleteRequest", e);
      return false;
    } catch (e) {
      return false;
    }
  }

  /**
   * Invia richiesta di modifica/annullamento.
   */
  Future<bool> sendModificationRequest(int requestId, String type, String note) async {
    try {
      final response = await _dio.post(
        '/requests/$requestId/action-request',
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
    } catch (e) {
      return false;
    }
  }

  /**
   * Recupera tutte le richieste (Admin/Planner).
   */
  Future<List<TransportRequest>> getAllRequests() async {
    try {
      final response = await _dio.get('/requests');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => TransportRequest.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      _logDioError("getAllRequests", e);
      return [];
    } catch (e) {
      return [];
    }
  }

  void _logDioError(String methodName, DioException e) {
    print("--- ERRORE DIO ($methodName) ---");
    print("Status: ${e.response?.statusCode}");
    print("Message: ${e.message}");
  }
}