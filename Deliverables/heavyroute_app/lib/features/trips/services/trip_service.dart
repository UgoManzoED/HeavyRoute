import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../../../core/models/geo_location.dart';
import '../../planner/presentation/service/mapbox_service.dart';
import '../../../core/network/dio_client.dart';
import '../models/route_model.dart';
import '../models/trip_model.dart';

/// Service Layer dedicato alla gestione del ciclo di vita dei Viaggi (Trips).
class TripService {
  final Dio _dio = DioClient.instance;
  final MapboxService _mapboxService = MapboxService();

  /// Recupera tutti i viaggi dal backend.
  /// <p>
  /// <b>Backend Endpoint:</b> GET /api/trips
  /// </p>
  Future<List<TripModel>> getAllTrips() async {
    const String endpoint = '/api/trips';

    try {
      debugPrint("🚀 Chiamata GET: $endpoint");
      final response = await _dio.get(endpoint);

      developer.log("📦 JSON RICEVUTO:", name: "TRIP_SERVICE"); // Scommenta se serve

      final List<dynamic> rawList = response.data;
      List<TripModel> parsedTrips = [];

      for (var i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        try {
          parsedTrips.add(TripModel.fromJson(item));
        } catch (e) {
          debugPrint("\n🔴 ERRORE DI PARSING all'elemento indice $i!");
          _analyzeParsingError(item);
          debugPrint("Errore specifico Dart: $e\n");
        }
      }
      return parsedTrips;

    } on DioException catch (e) {
      debugPrint("🛑 ERRORE DIO ($endpoint): ${e.response?.statusCode}");
      return [];
    } catch (e) {
      debugPrint("🛑 ERRORE GENERICO ($endpoint): $e");
      return [];
    }
  }

  /// Approva una richiesta di trasporto (Planner).
  Future<bool> approveRequest(int requestId) async {
    final String endpoint = '/api/trips/$requestId/approve';

    try {
      debugPrint("Chiamata POST: $endpoint");
      final response = await _dio.post(endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("🛑 ERRORE approveRequest: $e");
      return false;
    }
  }

  Future<bool> validateRoute(int tripId) async {
    final String endpoint = '/api/trips/$tripId/route/approve';

    try {
      debugPrint("Validazione Rotta: POST $endpoint");

      final response = await _dio.post(endpoint);

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("✅ Rotta validata con successo!");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("🛑 ERRORE validateRoute: $e");
      return false;
    }
  }

  /// Calcola opzioni di percorso reali usando Mapbox.
  Future<List<RouteModel>> getRealRouteOptions(String originAddress, String destAddress) async {
    List<RouteModel> options = [];
    debugPrint("🔍 Geocoding: $originAddress -> $destAddress");

    final GeoLocation? start = await _mapboxService.getCoordinates(originAddress);
    final GeoLocation? end = await _mapboxService.getCoordinates(destAddress);

    if (start == null || end == null) return [];

    // Opzione A: Traffico
    final routeA = await _mapboxService.calculateRoute(start, end, 'driving-traffic');
    if (routeA != null) {
      options.add(RouteModel(
          id: 1,
          description: "Rapido (Traffico Real-time)",
          distanceKm: routeA.distanceKm,
          durationHours: routeA.durationHours,
          tollCost: routeA.tollCost,
          isHazmatSuitable: true,
          polyline: routeA.polyline
      ));
    }

    // Opzione B: Standard
    final routeB = await _mapboxService.calculateRoute(start, end, 'driving');
    if (routeB != null) {
      options.add(RouteModel(
          id: 2,
          description: "Standard (Percorso Breve)",
          distanceKm: routeB.distanceKm,
          durationHours: routeB.durationHours,
          tollCost: routeB.tollCost * 0.9,
          isHazmatSuitable: true,
          polyline: routeB.polyline
      ));
    }
    return options;
  }

  /// Funzione Helper per scovare i null
  void _analyzeParsingError(Map<String, dynamic> json) {
    debugPrint("🔍 ANALISI CAMPI CRITICI:");
    if (json['id'] == null) debugPrint("ID MANCANTE");
    if (json['driverId'] == null) debugPrint("driverId è NULL (Ok se nullable)");
  }
}