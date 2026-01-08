import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

/// Middleware per la gestione automatica dell'autenticazione JWT.
/// <p>
/// Questa classe intercetta ogni chiamata HTTP in uscita e in entrata.
/// Il suo scopo principale è "iniettare" il token di sicurezza nell'header
/// senza che il codice della UI debba preoccuparsene.
/// </p>
class AuthInterceptor extends Interceptor {

  /// Eseguito PRIMA che la richiesta venga inviata al server.
  /// Qui trasformiamo una richiesta anonima in una richiesta autenticata.
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {

    // 1. Recupero Asincrono
    final token = await TokenStorage.getToken();

    // 2. Injection del Token
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print("Interceptor: Token aggiunto alla richiesta ${options.path}");
    }

    // 3. Passaggio del testimone
    return super.onRequest(options, handler);
  }

  /// Eseguito QUANDO il server risponde con un errore (es. 4xx o 5xx).
  /// Utile per gestire globalmente la scadenza della sessione.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check specifico per il 401 Unauthorized
    if (err.response?.statusCode == 401) {
      print("Errore 401: Token non valido o scaduto");

      // TODO: Implementare logica di Force Logout.
      // Esempio:
      // 1. TokenStorage.deleteToken(); // Pulisce il token marcio
      // 2. navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
      // Questo reindirizza l'utente alla login, prevenendo crash o stati inconsistenti.
    }
    super.onError(err, handler);
  }
}