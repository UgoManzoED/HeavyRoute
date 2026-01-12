import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import '../../../core/network/dio_client.dart';
import '../../../core/models/geo_location.dart';
import '../../planner/presentation/service/mapbox_service.dart';
import '../models/route_model.dart';
import '../models/trip_model.dart';

/// Service Layer dedicato alla gestione del ciclo di vita dei Viaggi (Trips).
/// <p>
/// Questa classe funge da bridge tra il Frontend Flutter e le API di Backend Spring Boot.
/// Gestisce il recupero dati, la validazione delle rotte (tramite Mapbox e Backend)
/// e l'assegnazione delle risorse (Autisti e Veicoli).
/// </p>
class TripService {
  final Dio _dio = DioClient.instance;
  final MapboxService _mapboxService = MapboxService();

  /// Recupera tutti i viaggi dal backend.
  /// <p>
  /// <b>Backend Endpoint:</b> GET /api/trips<br>
  /// Utilizzato per popolare la Dashboard principale e la lista storica.
  /// Include un meccanismo di try-catch robusto per analizzare errori di parsing JSON.
  /// </p>
  Future<List<TripModel>> getAllTrips() async {
    const String endpoint = '/api/trips';

    try {
      debugPrint("🚀 Chiamata GET: $endpoint");
      final response = await _dio.get(endpoint);

      // developer.log("📦 JSON RICEVUTO:", name: "TRIP_SERVICE", error: response.data);

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

  /// Recupera solo i viaggi che sono nello stato IN_PLANNING.
  /// <p>
  /// <b>Backend Endpoint:</b> GET /api/trips/planning<br>
  /// Utilizzato specificamente nella vista di pianificazione per mostrare
  /// i viaggi che necessitano di assegnazione risorse.
  /// </p>
  Future<List<TripModel>> getTripsToPlan() async {
    const String endpoint = '/api/trips/planning';
    try {
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).map((json) => TripModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("🛑 Errore getTripsToPlan: $e");
      return [];
    }
  }

  /// Approva una richiesta di trasporto iniziale.
  /// <p>
  /// <b>Backend Endpoint:</b> POST /api/trips/{requestId}/approve<br>
  /// Trasforma una TransportRequest in un Trip operativo.
  /// </p>
  ///
  /// @param requestId L'ID della richiesta da approvare.
  /// @return true se l'operazione ha successo.
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

  /// Calcola opzioni di percorso reali usando Mapbox.
  /// <p>
  /// Non chiama il backend Java, ma interagisce direttamente con le API di Mapbox
  /// tramite il {@link MapboxService} per ottenere dati geospaziali in tempo reale.
  /// </p>
  ///
  /// @param originAddress Indirizzo di partenza.
  /// @param destAddress Indirizzo di destinazione.
  /// @return Una lista di opzioni di percorso (es. Rapido vs Standard).
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

  /// Valida la rotta proposta (Azione del Coordinator).
  /// <p>
  /// <b>Backend Endpoint:</b> POST /api/trips/{tripId}/route/approve<br>
  /// Conferma che il percorso calcolato è sicuro e appropriato.
  /// </p>
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

  /// Recupera la lista degli autisti attualmente liberi.
  /// <p>
  /// <b>Backend Endpoint:</b> GET /api/resources/drivers/available<br>
  /// Filtra lato server solo gli autisti con stato {@code FREE}.
  /// </p>
  Future<List<dynamic>> getAvailableDrivers() async {
    try {
      final response = await _dio.get('/api/resources/drivers/available');
      return response.data ?? [];
    } catch (e) {
      debugPrint("🛑 Errore getAvailableDrivers: $e");
      return [];
    }
  }

  /// Recupera la lista dei veicoli attualmente disponibili.
  /// <p>
  /// <b>Backend Endpoint:</b> GET /api/resources/vehicles/available<br>
  /// Filtra lato server solo i veicoli con stato {@code AVAILABLE}.
  /// </p>
  Future<List<dynamic>> getAvailableVehicles() async {
    try {
      final response = await _dio.get('/api/resources/vehicles/available');
      return response.data ?? [];
    } catch (e) {
      debugPrint("🛑 Errore getAvailableVehicles: $e");
      return [];
    }
  }

  /// Assegna Autista e Veicolo al viaggio (Pianificazione).
  /// <p>
  /// <b>Backend Endpoint:</b> PUT /api/trips/{id}/plan<br>
  /// Finalizza la pianificazione associando le risorse selezionate al viaggio.
  /// </p>
  ///
  /// @param tripId L'ID del viaggio.
  /// @param driverId L'ID dell'autista selezionato.
  /// @param vehiclePlate La targa del veicolo selezionato.
  Future<bool> assignResources(int tripId, int driverId, String vehiclePlate) async {
    final String endpoint = '/api/trips/$tripId/plan';
    try {
      final response = await _dio.put(
        endpoint,
        data: {
          'driverId': driverId,
          'vehiclePlate': vehiclePlate,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("🛑 Errore assignResources: $e");
      return false;
    }
  }

  /// Funzione Helper privata per analizzare errori di parsing JSON.
  /// <p>
  /// Stampa in console i campi critici mancanti per facilitare il debugging
  /// quando {@code TripModel.fromJson} fallisce.
  /// </p>
  void _analyzeParsingError(Map<String, dynamic> json) {
    debugPrint("🔍 ANALISI CAMPI CRITICI:");
    if (json['id'] == null) debugPrint("ID MANCANTE");
    if (json['driverId'] == null) debugPrint("driverId è NULL (Ok se nullable)");
    // Aggiungi qui altri controlli se necessario
  }
}