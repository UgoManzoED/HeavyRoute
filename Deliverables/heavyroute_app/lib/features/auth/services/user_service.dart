import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

/// Servizio che gestisce le chiamate API per i dati utente (Profilo).
class UserService {
  final Dio _dio = DioClient.instance;

  /// Recupera i dati dell'utente corrente (/users/me).
  ///
  /// Restituisce un [UserModel] (che contiene id, ruolo, e campi specifici
  /// come patente o p.iva a seconda del ruolo).
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');

      if (response.statusCode == 200 && response.data != null) {
        if (kDebugMode) {
          print("✅ Dati Utente Ricevuti: ${response.data}");
        }
        // Deserializza nel nuovo modello unificato
        return UserModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      debugPrint("🛑 Errore API (GetCurrentUser): ${e.response?.statusCode}");
      return null;
    } catch (e) {
      debugPrint("🛑 Errore generico (GetCurrentUser): $e");
      return null;
    }
  }

  Future<List<UserModel>> getInternalUsers() async {
    try {
      // Assicurati che l'endpoint del backend restituisca la lista filtrata
      // Se il backend non ha un endpoint specifico, usa '/users' e filtra lato client (meno efficiente ma funziona)
      final response = await _dio.get('/users/internal');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        // La magia di json_serializable:
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Errore getInternalUsers: $e");
      return [];
    }
  }

  /// Aggiorna i dati dell'utente corrente.
  ///
  /// NOTA: In un'applicazione reale, l'oggetto di update spesso differisce
  /// dal modello di lettura (es. non puoi aggiornare l'ID o il Ruolo).
  /// Per ora inviamo il [UserModel], ma il backend dovrebbe ignorare i campi non modificabili.
  Future<bool> updateUser(UserModel userData) async {
    try {
      final response = await _dio.put(
        '/users/me',
        data: userData.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("✅ Dati utente aggiornati con successo.");
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("🛑 Errore API (UpdateUser): ${e.response?.statusCode} - ${e.response?.data}");
      return false;
    } catch (e) {
      debugPrint("🛑 Errore generico (UpdateUser): $e");
      return false;
    }
  }

  /// Modifica un utente specifico (per Account Manager)
  Future<bool> updateInternalUser(int id, UserModel userData) async {
    try {
      final response = await _dio.put(
        '/users/$id', // Chiama l'endpoint creato sopra
        data: userData.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Errore updateInternalUser: $e");
      return false;
    }
  }

  /// Crea un nuovo utente interno
  Future<bool> createInternalUser(UserModel userData) async {
    try {
      final response = await _dio.post(
        '/users/internal',
        data: userData.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Errore createInternalUser: $e");
      return false;
    }
  }

  /// Esegue il logout.
  ///
  /// Pulisce il TokenStorage (JWT e Ruolo) per forzare il login al prossimo avvio.
  Future<void> logout() async {
    await TokenStorage.deleteAll();
    debugPrint("🚪 Logout eseguito: Sessione locale rimossa.");
  }
}