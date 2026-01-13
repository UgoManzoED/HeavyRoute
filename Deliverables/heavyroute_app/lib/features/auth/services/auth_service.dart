import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- Import necessario
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';

/// Service responsabile della gestione della sessione utente.
class AuthService {
  final Dio _dio = DioClient.instance;

  /// Effettua il login e inizializza la sessione sicura.
  Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final String token = response.data['token'];
        final String role = response.data['role'];
        final int? userId = response.data['id']; // <--- Recuperiamo l'ID dal JSON

        // Utilizziamo i metodi del tuo TokenStorage
        await TokenStorage.saveToken(token);
        await TokenStorage.saveRole(role);

        // <--- SALVIAMO L'ID (Per usarlo nel DriverTripService)
        if (userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId);
          print("💾 ID Utente salvato: $userId");
        }

        print("Login Successo! Ruolo memorizzato: $role");
        return role;
      }
      return null;
    } on DioException catch (e) {
      print("Errore Login: ${e.response?.statusCode}");
      return null;
    } catch (e) {
      print("Errore Generico: $e");
      return null;
    }
  }

  /// Esegue il logout distruggendo l'intera sessione locale.
  /// Sfrutta il metodo deleteAll() per rimuovere JWT e Ruolo contemporaneamente.
  Future<void> logout() async {
    // MODIFICA: Chiamata al metodo unico di pulizia
    await TokenStorage.deleteAll();

    // <--- RIMUOVIAMO ANCHE L'ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    print("Logout eseguito: Storage sicuro resettato.");
  }
}