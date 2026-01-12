import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Serve per kDebugMode e kIsWeb
import 'auth_interceptor.dart';

/// Configurazione Singleton del client HTTP.
/// <p>
/// Questa classe è il cuore della comunicazione di rete.
/// Configura l'URL base, i timeout e aggiunge logger per il debug.
/// </p>
class DioClient {
  static final String _baseUrl = kIsWeb
      ? 'http://localhost:8080'
      : 'http://10.0.2.2:8080';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )
  // 1. Aggiungiamo intercettore per il Token
    ..interceptors.add(AuthInterceptor())

  // 2. Logger manuale per il Debug
    ..interceptors.add(
      InterceptorsWrapper(
        // PRIMA che la richiesta parta
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('---------------------------------------------------');
            print('📡 [REQ] INVIO: ${options.method} ${options.path}');
            print('   Dati: ${options.data}');
          }
          return handler.next(options);
        },

        // QUANDO la risposta arriva con successo (200/201)
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ [RES] OK (${response.statusCode}): ${response.requestOptions.path}');
          }
          return handler.next(response);
        },

        // QUANDO c'è un errore (403, 404, 500...)
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('---------------------------------------------------');
            print('🛑 [ERR] ERRORE RILEVATO!');
            print('   URL COLPEVOLE: ${e.requestOptions.path}');
            print('   Metodo: ${e.requestOptions.method}');
            print('   Status Code: ${e.response?.statusCode}');
            print('   Risposta Server: ${e.response?.data}');
            print('---------------------------------------------------');
          }
          return handler.next(e);
        },
      ),
    );

  static Dio get instance => _dio;
}