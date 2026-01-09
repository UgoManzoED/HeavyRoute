import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/user_dto.dart';

/**
 * Servizio che gestisce le chiamate API per i dati utente.
 * Utilizza un'istanza centralizzata di Dio per le operazioni di rete.
 * @author Roman
 * @version 1.0
 */
class UserService {
  /** Istanza di Dio ottenuta dal client di rete core */
  final Dio _dio = DioClient.instance;

  /**
   * Recupera i dati dell'utente corrente.
   * @return Un [UserDTO] con i dati utente. In caso di errore, restituisce null.
   */
  Future<UserDTO?> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');

      if (response.statusCode == 200 && response.data != null) {
        return UserDTO.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print("Errore API (GetCurrentUser): ${e.response?.statusCode} - ${e.response?.data}");
      return null;
    } catch (e) {
      print("Errore generico (GetCurrentUser): $e");
      return null;
    }
  }

  /**
   * Aggiorna i dati dell'utente corrente.
   * @param userData I dati utente da aggiornare.
   * @return [bool] true se l'operazione ha avuto successo, false altrimenti.
   */
  Future<bool> updateUser(UserDTO userData) async {
    try {
      final response = await _dio.put(
        '/users/me',
        data: userData.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Successo! Dati utente aggiornati: ${response.data}");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Errore API (UpdateUser): ${e.response?.statusCode} - ${e.response?.data}");
      return false;
    } catch (e) {
      print("Errore generico (UpdateUser): $e");
      return false;
    }
  }
}
