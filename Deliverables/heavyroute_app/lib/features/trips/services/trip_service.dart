import 'package:dio/dio.dart';
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
    try {
      final response = await _dio.post('/trips/$requestId/approve');
      return response.statusCode == 200;
    } on DioException catch (e) {
      // Gestione errori specifica per chiamate HTTP
      print("--- ERRORE APPROVAZIONE TRIP ---");
      print("Status Code: ${e.response?.statusCode}");
      print("Messaggio Server: ${e.response?.data}");
      return false;

    } catch (e) {
      // Gestione errori imprevisti
      print("Errore generico in approveRequest: $e");
      return false;
    }
  }
}