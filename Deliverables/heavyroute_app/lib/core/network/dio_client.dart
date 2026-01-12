import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_interceptor.dart';

/// Configurazione Singleton del client HTTP.
/// <p>
/// Questa classe è il cuore della comunicazione di rete.
/// Configura l'URL base, i timeout e, soprattutto, aggancia l'Interceptor
/// di sicurezza per automatizzare l'invio del Token JWT.
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
  )..interceptors.add(AuthInterceptor());

  static Dio get instance => _dio;
}