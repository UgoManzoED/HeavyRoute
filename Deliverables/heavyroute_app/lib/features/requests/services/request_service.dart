import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/request_dto.dart';
import '../models/request_detail_dto.dart';

/**
 * Servizio che gestisce le chiamate API per le richieste di trasporto.
 * Utilizza un'istanza centralizzata di Dio per le operazioni di rete.
 * * @author Roman
 * @version 1.2
 */
class RequestService {
  /** Istanza di Dio ottenuta dal client di rete core */
  final Dio _dio = DioClient.instance;

  /**
   * Recupera la lista delle richieste dettagliate associate all'utente corrente.
   * Include informazioni aggiuntive come ID e stato (PENDING/APPROVED).
   *
   * @return Una lista di [RequestDetailDTO]. In caso di errore, restituisce una lista vuota.
   */
  Future<List<RequestDetailDTO>> getMyRequests() async {
    try {
      // L'endpoint nel backend è "/my-requests", non "/me"
      final response = await _dio.get('/requests/my-requests');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => RequestDetailDTO.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      // LOG MIGLIORATI PER IL DEBUG
      print("--- ERRORE DIO (GetRequestDetails) ---");
      print("Tipo: ${e.type}");
      print("Messaggio: ${e.message}");
      print("Risposta Server: ${e.response?.data}");
      return [];
    } catch (e) {
      print("Errore generico (GetRequestDetails): $e");
      return [];
    }
  }

  /**
   * Invia una nuova richiesta di trasporto al server.
   * * @param dto L'oggetto contenente i dati della richiesta da creare.
   * @return [bool] true se l'operazione ha avuto successo, false altrimenti.
   */
  Future<bool> createRequest(RequestCreationDTO dto) async {
    try {
      final response = await _dio.post(
        '/requests',
        data: dto.toJson(),
      );

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

  // --- METODI DEPRECATED ---

  /**
   * @deprecated Usare getMyRequests() che usa il DTO corretto per la lettura.
   */
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