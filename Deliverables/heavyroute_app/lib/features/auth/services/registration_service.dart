import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dto/auth_requests.dart';

/// Service responsabile della registrazione Clienti.
///
/// Gestisce la comunicazione HTTP e la normalizzazione degli errori RFC 7807
/// (ProblemDetails) di Spring Boot in una mappa per la UI.
class RegistrationService {
  final Dio _dio = DioClient.instance;

  /// Invia la richiesta di registrazione.
  ///
  /// Restituisce:
  /// - `null`: Se successo.
  /// - `Map<String, dynamic>`: Mappa degli errori {campo: messaggio}.
  Future<Map<String, dynamic>?> registerClient(CustomerRegistrationRequest request) async {
    try {
      // NOTA: Verifica che l'endpoint nel backend corrisponda esattamente a questo path.
      // Se il Controller ha @RequestMapping("/api/users"), allora qui va bene.
      final response = await _dio.post(
        '/users/register/client',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // SUCCESSO
      }
      return {'global': 'Errore imprevisto: ${response.statusCode}'};

    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      debugPrint("🛑 ERRORE DART GENERICO: $e");
      return {'global': 'Errore interno app: $e'};
    }
  }

  /// Metodo privato per pulire la logica di gestione errori
  Map<String, dynamic> _handleDioError(DioException e) {
    if (kDebugMode) {
      debugPrint("🛑 ERRORE HTTP: ${e.response?.statusCode}");
      debugPrint("🛑 BODY: ${e.response?.data}");
    }

    final data = e.response?.data;

    // 1. Errore di connessione o server giù
    if (data == null) {
      return {'global': 'Nessuna risposta dal server. Controlla la connessione.'};
    }

    // 2. Analisi del body JSON
    if (data is Map<String, dynamic>) {

      // CASO A: Errori di Validazione (@Valid fallito nel DTO backend)
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map) {
          return Map<String, dynamic>.from(errors);
        }
      }

      // CASO B: Eccezioni di Business (BusinessRuleException)
      if (data.containsKey('detail') && data['detail'] != null) {
        String detail = data['detail'].toString();

        // Tentativo di mappare il messaggio testuale sul campo specifico del form.
        if (detail.toLowerCase().contains("partita iva")) {
          return {'vatNumber': detail};
        }
        if (detail.toLowerCase().contains("username")) {
          return {'username': detail};
        }
        if (detail.toLowerCase().contains("email")) {
          return {'email': detail};
        }
        if (detail.toLowerCase().contains("pec")) {
          return {'pec': detail};
        }
        if (detail.toLowerCase().contains("targa")) {
          return {'vehiclePlate': detail};
        }

        // Se non riconosciamo la parola chiave, mostriamo l'errore generico
        return {'global': detail};
      }

      // CASO C: Fallback su 'title' o 'message'
      if (data.containsKey('title')) return {'global': data['title']};
      if (data.containsKey('message')) return {'global': data['message']};
    }

    return {'global': 'Errore server (${e.response?.statusCode}): Impossibile leggere i dettagli.'};
  }
}