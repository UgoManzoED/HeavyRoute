import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';

/// Service responsabile della gestione della sessione utente.
/// Collega il livello di rete (Dio) con il livello di persistenza sicura (TokenStorage).
class AuthService {
  final Dio _dio = DioClient.instance;

  /// Effettua il login e inizializza la sessione sicura.
  ///
  /// @param username L'identificativo utente (email o username).
  /// @param password La password in chiaro (verrà inviata via HTTPS).
  /// @return `true` se il login ha successo e il token è stato salvato, `false` altrimenti.
  Future<bool> login(String username, String password) async {
    try {
      // Chiama l'endpoint del backend
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Estrai il token dalla risposta
        final String token = response.data['token'];

        // Salva il token in modo sicuro
        await TokenStorage.saveToken(token);

        print("Login Successo! Token salvato.");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Errore Login: ${e.response?.statusCode} - ${e.response?.data}");
      return false;
    } catch (e) {
      print("Errore Generico: $e");
      return false;
    }
  }

  /// Esegue il logout distruggendo la sessione locale.
  /// Non chiama il backend (i JWT sono stateless), si limita a dimenticare il token.
  Future<void> logout() async {
    await TokenStorage.deleteToken();
  }
}