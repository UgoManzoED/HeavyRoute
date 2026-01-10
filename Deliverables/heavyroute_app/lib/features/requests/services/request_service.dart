import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/request_dto.dart';
import '../models/request_detail_dto.dart';

/**
 * Service Layer per la gestione delle Richieste di Trasporto.
 * <p>
 * Questa classe incapsula tutte le interazioni HTTP relative al dominio "Requests".
 * Isola la complessità di rete (endpoint, header, serializzazione) dai Widget della UI.
 * </p>
 * @author Roman
 */
class RequestService {
  /** Istanza del client HTTP configurato con interceptor per il Token JWT. */
  final Dio _dio = DioClient.instance;

  /**
   * Recupera la lista delle richieste appartenenti all'utente loggato.
   * <p>
   * <b>Caso d'uso:</b> Popola la lista nella schermata "I Miei Ordini" del Committente.
   * </p>
   * @return Una lista di {@link RequestDetailDTO} popolata, o una lista vuota in caso di errore.
   */
  Future<List<RequestDetailDTO>> getMyRequests() async {
    try {
      final response = await _dio.get('/requests/my-requests');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => RequestDetailDTO.fromJson(json)).toList();
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
   * Invia una nuova richiesta di trasporto al backend.
   *
   * @param dto Il DTO di creazione {@link RequestCreationDTO}.
   * @return [true] se l'operazione ha avuto successo (200/201).
   */
  Future<bool> createRequest(RequestCreationDTO dto) async {
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
   * Elimina definitivamente una richiesta di trasporto dal sistema.
   * <p>
   * <b>Nota:</b> L'operazione è permessa solo se la richiesta non è ancora
   * stata presa in carico (Stato PENDING).
   * </p>
   * @param requestId L'identificativo univoco della richiesta.
   * @return [true] se l'eliminazione è stata confermata dal server.
   */
  Future<bool> deleteRequest(String requestId) async {
    try {
      final response = await _dio.delete('/requests/$requestId');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      _logDioError("deleteRequest", e);
      return false;
    } catch (e) {
      print("Errore generico (deleteRequest): $e");
      return false;
    }
  }

  /**
   * Invia una richiesta formale di modifica o annullamento per un ordine.
   * <p>
   * Questo metodo viene invocato dal popup di azione del committente quando
   * l'ordine è in uno stato che non permette l'eliminazione diretta.
   * </p>
   * @param requestId ID della richiesta da modificare/annullare.
   * @param type Tipologia di azione (es. 'MODIFICA' o 'ANNULLAMENTO').
   * @param note Testo descrittivo inserito dall'utente.
   * @return [true] se la segnalazione è stata inoltrata correttamente al team logistico.
   */
  Future<bool> sendModificationRequest(String requestId, String type, String note) async {
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
      print("Errore generico (sendModificationRequest): $e");
      return false;
    }
  }

  /**
   * Recupera la lista globale delle richieste (Accesso riservato al Planner).
   * @return Lista completa delle richieste presenti nel sistema.
   */
  Future<List<RequestDetailDTO>> getAllRequests() async {
    try {
      final response = await _dio.get('/requests');
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

  /**
   * Metodo helper per il logging standardizzato degli errori di rete.
   */
  void _logDioError(String methodName, DioException e) {
    print("--- ERRORE DIO ($methodName) ---");
    print("Status: ${e.response?.statusCode}");
    print("Messaggio: ${e.message}");
    print("Body: ${e.response?.data}");
  }
}