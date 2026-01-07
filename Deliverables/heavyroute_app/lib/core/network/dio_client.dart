import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  // Se usi un emulatore Android, localhost è 10.0.2.2
  // Se usi iOS o Web, è localhost
  // Se usi un telefono vero, devi mettere l'IP del tuo PC (es. 192.168.1.X)
  static final String _baseUrl = kIsWeb
      ? 'http://localhost:8080/api'
      : 'http://10.0.2.2:8080/api';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static Dio get instance => _dio;
}