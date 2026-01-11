import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/geo_location.dart';
import '../../planner/presentation/service/mapbox_service.dart';
import '../../../core/network/dio_client.dart';
import '../models/route_model.dart';

/// Service Layer dedicato alla gestione del ciclo di vita dei Viaggi (Trips).
/// <p>
/// Gestisce le operazioni che trasformano una semplice richiesta di trasporto
/// in un ordine di viaggio operativo (es. Approvazione, Pianificazione, Assegnazione).
/// </p>
class TripService {
  // Utilizziamo l'istanza singleton configurata con Interceptor e BaseUrl
  final Dio _dio = DioClient.instance;
  final MapboxService _mapboxService = MapboxService();

  /// Approva una richiesta di trasporto pendente e genera il relativo Viaggio.
  /// <p>
  /// <b>Backend Endpoint:</b> POST /api/trips/{requestId}/approve
  /// </p>
  /// <p>
  /// Questa operazione è idempotente a livello di business: se la richiesta è già approvata,
  /// il backend restituirà un errore o ignorerà il comando.
  /// </p>
  ///
  /// @param requestId L'ID univoco della richiesta da approvare.
  /// @return [true] se il server risponde 200 OK (Viaggio creato), [false] altrimenti.
  Future<bool> approveRequest(int requestId) async {
    final String endpoint = '/trips/$requestId/approve';

    try {
      debugPrint("🚀 Chiamata POST: $endpoint");

      final response = await _dio.post(endpoint);

      debugPrint("✅ Risposta Backend: ${response.statusCode}");

      // 200 OK (Successo con dati)
      // 201 Created (Nuova risorsa creata)
      // 204 No Content (Successo ma body vuoto)
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      }

      return false;

    } on DioException catch (e) {
      debugPrint("🛑 ERRORE DIO ($endpoint)");
      debugPrint("Status: ${e.response?.statusCode}");
      debugPrint("Data: ${e.response?.data}");

      // Se l'errore è 409 (Conflict) o 400
      return false;
    } catch (e) {
      debugPrint("🛑 ERRORE GENERICO ($endpoint): $e");
      return false;
    }
  }

  Future<List<RouteModel>> getRealRouteOptions(String originAddress, String destAddress) async {
    List<RouteModel> options = [];

    // 1. Otteniamo le coordinate reali
    debugPrint("🔍 Geocoding: $originAddress -> $destAddress");
    final GeoLocation? start = await _mapboxService.getCoordinates(originAddress);
    final GeoLocation? end = await _mapboxService.getCoordinates(destAddress);

    if (start == null || end == null) {
      debugPrint("❌ Impossibile trovare coordinate per gli indirizzi.");
      return [];
    }

    // 2. Chiediamo 2 profili diversi a Mapbox (es. Con Traffico e Normale)

    // Opzione A: Guida con Traffico
    final routeA = await _mapboxService.calculateRoute(start, end, 'driving-traffic');
    if (routeA != null) {
      // Creiamo una copia con descrizione custom
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

    // Opzione B: Guida Classica
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
}