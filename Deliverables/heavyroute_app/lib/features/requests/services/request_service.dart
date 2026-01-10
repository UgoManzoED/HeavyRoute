import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/request_dto.dart';
import '../models/request_detail_dto.dart';

/// Service Layer per la gestione delle Richieste di Trasporto.
/// <p>
/// Questa classe incapsula tutte le interazioni HTTP relative al dominio "Requests".
/// Isola la complessità di rete (endpoint, header, serializzazione) dai Widget della UI.
/// </p>
class RequestService {
  // DIPENDENZA: Client HTTP
  // -----------------------
  // Recuperiamo il singleton 'DioClient.instance'.
  // Questo è cruciale perché quell'istanza contiene l'AuthInterceptor.
  // Senza di esso, le chiamate partirebbero senza Token JWT e fallirebbero (401).
  final Dio _dio = DioClient.instance;

  /// Recupera la lista delle richieste appartenenti all'utente loggato.
  /// <p>
  /// <b>Caso d'uso:</b> Popola la lista nella schermata "I Miei Ordini" del Committente.
  /// </p>
  /// <p>
  /// <b>Mapping:</b> Riceve un JSON Array e lo converte in una List<RequestDetailDTO>.
  /// Usa [RequestDetailDTO] perché in lettura ci servono ID e STATO (campi assenti nel DTO di creazione).
  /// </p>
  ///
  /// @return Una lista di DTO popolata, o una lista vuota in caso di errore.
  Future<List<RequestDetailDTO>> getMyRequests() async {
    try {
      // Endpoint specifico che filtra lato backend tramite il Token (User Isolation)
      final response = await _dio.get('/requests/my-requests');

      // 200 OK: La richiesta è andata a buon fine
      if (response.statusCode == 200 && response.data != null) {
        // Parsing della lista JSON:
        // 1. response.data è List<dynamic>
        // 2. .map() itera su ogni elemento JSON
        // 3. .fromJson() converte il singolo JSON in Oggetto Dart
        // 4. .toList() ricompatta il tutto in una lista tipizzata
        final List<dynamic> data = response.data;
        return data.map((json) => RequestDetailDTO.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      // Gestione specifica errori di rete (Timeout, 404, 500, DNS error)
      print("--- ERRORE DIO (GetRequestDetails) ---");
      print("Tipo: ${e.type}");
      print("Messaggio: ${e.message}");
      print("Risposta Server: ${e.response?.data}");
      return [];
    } catch (e) {
      // Catch-all per errori di programmazione (es. JSON malformato che fa crashare il parsing)
      print("Errore generico (GetRequestDetails): $e");
      return [];
    }
  }

  /// Invia una nuova richiesta di trasporto al backend.
  /// <p>
  /// <b>Caso d'uso:</b> Premendo "Invia" nel form di creazione richiesta.
  /// </p>
  ///
  /// @param dto Il DTO di "Creazione" (senza ID, senza Stato) contenente i dati del form.
  /// @return [true] se il server ha salvato (200/201), [false] altrimenti.
  Future<bool> createRequest(RequestCreationDTO dto) async {
    try {
      // Serializzazione: dto.toJson() trasforma l'oggetto Dart in Map<String, dynamic>
      // che Dio converte automaticamente in stringa JSON nel body della POST.
      final response = await _dio.post(
        '/requests',
        data: dto.toJson(),
      );

      // Gestiamo sia 200 (OK) che 201 (Created) come successo
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Successo! Risposta server: ${response.data}");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("--- ERRORE DIO (CreateRequest) ---");
      print("Tipo: ${e.type}");
      print("Messaggio: ${e.message}");
      print("Risposta Server: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Errore generico: $e");
      return false;
    }
  }

  /// Recupera TUTTE le richieste presenti nel sistema.
  /// <p>
  /// <b>Access Control:</b> Questo metodo funzionerà SOLO se l'utente loggato ha ruolo
  /// <b>LOGISTIC_PLANNER</b>. Se un Driver o un Cliente prova a chiamarlo,
  /// il Backend risponderà con 403 Forbidden e questo metodo restituirà lista vuota.
  /// </p>
  Future<List<RequestDetailDTO>> getAllRequests() async {
    try {
      final response = await _dio.get('/requests'); // Endpoint per il PL

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => RequestDetailDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Errore getAllRequests: $e");
      return [];
    }
  }

  // --- METODI DEPRECATED ---

  /// Vecchio metodo per il recupero richieste.
  ///
  /// @deprecated
  /// <b>Motivo:</b> Restituiva [RequestCreationDTO] che è un oggetto incompleto per la lettura
  /// (manca ID e Stato). Usare [getMyRequests] che restituisce [RequestDetailDTO].
  Future<List<RequestCreationDTO>> getMyRequestCreations() async {
    try {
      final response = await _dio.get('/requests/my-requests');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => RequestCreationDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Errore metodo deprecato: $e");
      return [];
    }
  }
}