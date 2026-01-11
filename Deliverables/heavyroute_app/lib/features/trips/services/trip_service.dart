import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';

/// Service Layer dedicato alla gestione del ciclo di vita dei Viaggi (Trips).
/// <p>
/// Gestisce le operazioni che trasformano una semplice richiesta di trasporto
/// in un ordine di viaggio operativo (es. Approvazione, Pianificazione, Assegnazione).
/// </p>
class TripService {
  // Utilizziamo l'istanza singleton configurata con Interceptor e BaseUrl
  final Dio _dio = DioClient.instance;

  /// Approva una richiesta di trasporto pendente e genera il relativo Viaggio.
  /// <p>
  /// <b>Backend Endpoint:</b> POST /api/trips/{requestId}/approve
  /// </p>
  /// <p>
  /// Questa operazione è idempotente a livello di business: se la richiesta è già approvata,
  /// il backend restituirà un errore o ignorerà il comando.
  /// </p>
  ///
  /// @param requestId L'ID univoco della richiesta da approvare.
  /// @return [true] se il server risponde 200 OK (Viaggio creato), [false] altrimenti.
  Future<bool> approveRequest(int requestId) async {
    final String endpoint = '/trips/$requestId/approve';

    try {
      debugPrint("🚀 Chiamata POST: $endpoint");

      final response = await _dio.post(endpoint);

      debugPrint("✅ Risposta Backend: ${response.statusCode}");

      // 200 OK (Successo con dati)
      // 201 Created (Nuova risorsa creata)
      // 204 No Content (Successo ma body vuoto)
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      }

      return false;

    } on DioException catch (e) {
      debugPrint("🛑 ERRORE DIO ($endpoint)");
      debugPrint("Status: ${e.response?.statusCode}");
      debugPrint("Data: ${e.response?.data}");

      // Se l'errore è 409 (Conflict) o 400
      return false;
    } catch (e) {
      debugPrint("🛑 ERRORE GENERICO ($endpoint): $e");
      return false;
    }
  }
}