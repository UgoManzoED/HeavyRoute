import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Classe di utilità per la gestione persistente e sicura del Token di Autenticazione (JWT).
/// <p>
/// Agisce come un wrapper attorno alle API native di sicurezza:
/// - **iOS:** Keychain Services.
/// - **Android:** Keystore System & EncryptedSharedPreferences.
/// </p>
/// Non usare le normali 'SharedPreferences' per salvare token o password
class TokenStorage {

  // CONFIGURAZIONE DI SICUREZZA
  // ---------------------------
  // Per Android, abilitiamo esplicitamente 'encryptedSharedPreferences'.
  // Questo garantisce che i dati siano cifrati con chiavi gestite dall'Hardware (TEE),
  // rendendo il token illeggibile anche se qualcuno estrae i dati dell'app.
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyJwt = 'jwt_token';

  /// Salva il token ricevuto dal backend dopo il Login.
  /// <p>
  /// L'operazione è asincrona perché richiede I/O su disco e crittografia.
  /// </p>
  /// [token] La stringa JWT grezza (es. "eyJhbGciOiJIUz...")
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyJwt, value: token);
  }

  /// Recupera il token salvato per autenticare le chiamate API.
  /// <p>
  /// Da utilizzare all'interno dell'Interceptor di Dio per aggiungere
  /// l'header 'Authorization: Bearer ...'.
  /// </p>
  /// Ritorna `null` se l'utente non è loggato o il token è stato cancellato.
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyJwt);
  }

  /// Rimuove il token dallo storage sicuro (Logout).
  /// <p>
  /// Questa azione rende l'app "smemorizzata": al prossimo avvio l'utente
  /// dovrà inserire nuovamente le credenziali.
  /// </p>
  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyJwt);
  }
}