import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../features/trips/models/route_model.dart';

class HeavyRouteMap extends StatelessWidget {
  final RouteModel? route;

  const HeavyRouteMap({super.key, this.route});

  List<LatLng> _getPolylinePoints(String encodedPolyline) {
    if (encodedPolyline.isEmpty) return [];
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline);
    return result.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final String accessToken = dotenv.get('MAPBOX_ACCESS_TOKEN');

    // Punto di default (Italia)
    LatLng center = const LatLng(41.8719, 12.5674);
    double zoom = 6.0;

    // Se c'è una rotta, centriamo sull'inizio
    if (route != null && route!.startLat != null) {
      center = LatLng(route!.startLat!, route!.startLon!);
      zoom = 9.0;
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        // interactionOptions: const InteractionOptions(flags: InteractiveFlag.all), // Abilita zoom/pan
      ),
      children: [
        // 1. Layer Mappa
        TileLayer(
          urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$accessToken",

          additionalOptions: const {},

          userAgentPackageName: 'com.heavyroute.app',
          tileProvider: CancellableNetworkTileProvider(),
          retinaMode: true,
        ),

        // 2. Layer Percorso
        if (route != null && route!.polyline.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _getPolylinePoints(route!.polyline),
                color: Colors.blueAccent,
                strokeWidth: 5.0,
              ),
            ],
          ),

        // 3. Layer Marker
        if (route != null && route!.startLat != null && route!.endLat != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(route!.startLat!, route!.startLon!),
                width: 40,
                height: 40,
                child: const Icon(
                    Icons.location_on, color: Colors.green, size: 40),
              ),
              Marker(
                point: LatLng(route!.endLat!, route!.endLon!),
                width: 40,
                height: 40,
                child: const Icon(Icons.flag, color: Colors.red, size: 40),
              ),
            ],
          ),

        // Attribution
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© Mapbox', onTap: () {}),
            TextSourceAttribution('© OpenStreetMap', onTap: () {}),
          ],
        ),
      ],
    );
  }
}