import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/models/geo_location.dart';
import '../../../trips/models/route_model.dart';

class MapboxService {
  final Dio _dio = Dio();

  final String _accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  final String _baseUrl = 'https://api.mapbox.com';

  /// 1. GEOCODING: Trasforma "Via Roma, Napoli" in Lat/Lon
  Future<GeoLocation?> getCoordinates(String address) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/geocoding/v5/mapbox.places/$address.json',
        queryParameters: {
          'access_token': _accessToken,
          'limit': 1,
          'country': 'IT',
        },
      );

      if (response.statusCode == 200 && response.data['features'].isNotEmpty) {
        // Mapbox restituisce [longitudine, latitudine]
        final List center = response.data['features'][0]['center'];
        return GeoLocation(latitude: center[1], longitude: center[0]);
      }
      return null;
    } catch (e) {
      debugPrint("Errore Geocoding: $e");
      return null;
    }
  }

  /// 2. DIRECTIONS: Calcola il percorso tra due punti
  Future<RouteModel?> calculateRoute(GeoLocation start, GeoLocation end, String profile) async {
    // profile può essere 'driving-traffic', 'driving', 'cycling'
    try {
      final response = await _dio.get(
        '$_baseUrl/directions/v5/mapbox/$profile/${start.toMapboxString()};${end.toMapboxString()}',
        queryParameters: {
          'access_token': _accessToken,
          'geometries': 'polyline',
          'overview': 'full',
        },
      );

      if (response.statusCode == 200 && response.data['routes'].isNotEmpty) {
        final routeData = response.data['routes'][0];

        // Conversione Metri -> Km e Secondi -> Ore
        final double distanceKm = (routeData['distance'] / 1000);
        final double durationH = (routeData['duration'] / 3600);

        return RouteModel(
          id: 0,
          description: "Percorso Mapbox (${profile.split('-')[0]})",
          distanceKm: distanceKm,
          durationHours: durationH,
          tollCost: distanceKm * 0.15,
          isHazmatSuitable: true,
          polyline: routeData['geometry'],
        );
      }
      return null;
    } catch (e) {
      debugPrint("Errore Routing: $e");
      return null;
    }
  }
}