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

    // --- MODIFICA: LISTA DI ESCLUSIONE ---
    // Se la richiesta è per il Login o la Registrazione, NON inviare il token.
    if (options.path.contains('/api/auth/login') ||
        options.path.contains('/api/users/register')) {
      print("🔓 Interceptor: Richiesta pubblica (${options.path}), token saltato.");
      return super.onRequest(options, handler);
    }
    // -------------------------------------

    // 1. Recupera il token dalla memoria sicura
    final token = await TokenStorage.getToken();

    // 2. Se il token esiste, aggiungilo all'header
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print("🔐 Interceptor: Token aggiunto alla richiesta ${options.path}");
    }

    // 3. Procedi con la richiesta
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