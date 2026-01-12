import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_interceptor.dart';

/// Configurazione Singleton del client HTTP.
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
  // 1. Intercettore Token
    ..interceptors.add(AuthInterceptor())

  // 2. LOGGER COMPLETO PER DEBUG
    ..interceptors.add(
      InterceptorsWrapper(
        // --- RICHIESTA ---
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('\n==================== 📡 RICHIESTA ====================');
            print('URL: ${options.method} ${options.uri}'); // URL completo
            print('HEADERS:');
            options.headers.forEach((k, v) => print('   $k: $v'));

            if (options.data != null) {
              print('BODY (Payload):');
              try {
                var encoder = const JsonEncoder.withIndent('  ');
                print(encoder.convert(options.data));
              } catch (e) {
                print(options.data);
              }
            }
            print('======================================================\n');
          }
          return handler.next(options);
        },

        // --- RISPOSTA (SUCCESSO) ---
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('\n==================== ✅ RISPOSTA (${response.statusCode}) ====================');
            print('DA: ${response.requestOptions.path}');

            print('DATI RICEVUTI:');
            try {
              var encoder = const JsonEncoder.withIndent('  ');
              print(encoder.convert(response.data));
            } catch (e) {
              print(response.data);
            }
            print('======================================================\n');
          }
          return handler.next(response);
        },

        // --- ERRORE ---
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('\n==================== 🛑 ERRORE ====================');
            print('URL: ${e.requestOptions.method} ${e.requestOptions.path}');
            print('STATUS CODE: ${e.response?.statusCode}');
            print('MESSAGGIO: ${e.message}');

            if (e.response?.data != null) {
              print('DETTAGLI SERVER:');
              try {
                var encoder = const JsonEncoder.withIndent('  ');
                print(encoder.convert(e.response?.data));
              } catch (_) {
                print(e.response?.data);
              }
            }
            print('===================================================\n');
          }
          return handler.next(e);
        },
      ),
    );

  static Dio get instance => _dio;
}