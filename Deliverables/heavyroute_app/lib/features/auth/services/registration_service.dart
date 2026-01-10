import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/client_registration_dto.dart';

/// Service responsabile della registrazione Clienti.
/// <p>
/// Gestisce la comunicazione HTTP e, soprattutto, la <b>Normalizzazione degli Errori</b>.
/// Trasforma le risposte RFC 7807 (ProblemDetails) di Spring Boot in una mappa
/// semplice utilizzabile dal Form Flutter per evidenziare i campi errati.
/// </p>
class RegistrationService {
  final Dio _dio = DioClient.instance;

  /// Invia la richiesta di registrazione.
  ///
  /// @return
  /// - `null`: Se l'operazione ha successo (HTTP 200/201).
  /// - `Map<String, dynamic>`: Una mappa contenente gli errori.
  ///    - Chiave: Nome del campo (es. 'vatNumber') o 'global'.
  ///    - Valore: Messaggio di errore da mostrare all'utente.
  Future<Map<String, dynamic>?> registerClient(ClientRegistrationDTO dto) async {
    try {
      final response = await _dio.post(
        '/users/register/client',
        data: dto.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // SUCCESSO
      }
      return {'global': 'Errore imprevisto: ${response.statusCode}'};

    } on DioException catch (e) {
      // --- DEBUGGING ---
      print("🛑 ERRORE HTTP: ${e.response?.statusCode}");
      print("🛑 JSON GREZZO: ${e.response?.data}");
      print("🛑 TIPO DATO: ${e.response?.data.runtimeType}");
      // -------------------------------

      final data = e.response?.data;

      // 1. Se il server è giù o c'è un errore di rete puro
      if (data == null) {
        return {'global': 'Nessuna risposta dal server.'};
      }

      if (data is Map<String, dynamic>) {

        // CASO A: Errori di Validazione
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map) {
            return Map<String, dynamic>.from(errors);
          }
        }

        // CASO B: Eccezioni di Business
        if (data.containsKey('detail')) {
          String detail = data['detail'];

          if (detail.contains("Partita IVA")) {
            return {'vatNumber': detail};
          }
          if (detail.contains("username") || detail.contains("Username")) {
            return {'username': detail};
          }
          if (detail.contains("email") || detail.contains("Email")) {
            return {'email': detail};
          }
          if (detail.contains("PEC")) {
            return {'pec': detail};
          }

          // Altrimenti errore globale
          return {'global': detail};
        }

        // CASO C: Fallback
        if (data.containsKey('title')) {
          return {'global': data['title']};
        }
      }

      return {'global': 'Errore di connessione o dati non validi.'};
    } catch (e) {
      print("🛑 ERRORE DART: $e");
      return {'global': 'Errore interno app: $e'};
    }
  }
}