import 'dart:async'; // Serve per il Timer
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../features/trips/models/route_model.dart';

class HeavyRouteMap extends StatefulWidget {
  final RouteModel? route;

  const HeavyRouteMap({super.key, this.route});

  @override
  State<HeavyRouteMap> createState() => _HeavyRouteMapState();
}

class _HeavyRouteMapState extends State<HeavyRouteMap> {
  final MapController _mapController = MapController();
  List<LatLng> _cachedPoints = [];
  String? _lastPolyline;

  @override
  void didUpdateWidget(covariant HeavyRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se la rotta cambia, ricalcoliamo
    if (widget.route?.polyline != _lastPolyline) {
      _processRoute();
    }
  }

  @override
  void initState() {
    super.initState();
    _processRoute();
  }

  void _processRoute() {
    // 1. Reset se vuoto
    if (widget.route == null || widget.route!.polyline.isEmpty) {
      if (mounted) {
        setState(() {
          _cachedPoints = [];
          _lastPolyline = null;
        });
      }
      return;
    }

    _lastPolyline = widget.route!.polyline;

    try {
      // 2. Decodifica Punti (Precisione 5 standard)
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> result = polylinePoints.decodePolyline(widget.route!.polyline);
      final points = result.map((p) => LatLng(p.latitude, p.longitude)).toList();

      if (mounted) {
        setState(() {
          _cachedPoints = points;
        });
      }

      if (points.isNotEmpty) {
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            _zoomToFit(points);
          }
        });
      }
    } catch (e) {
      debugPrint("⚠️ Errore decodifica mappa: $e");
    }
  }

  void _zoomToFit(List<LatLng> points) {
    try {
      double minLat = 90.0, maxLat = -90.0, minLon = 180.0, maxLon = -180.0;
      for (var p in points) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLon) minLon = p.longitude;
        if (p.longitude > maxLon) maxLon = p.longitude;
      }

      if (minLat == 90.0) return;

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon)),
          padding: const EdgeInsets.all(50),
        ),
      );
    } catch (e) {
      debugPrint("⚠️ Errore Zoom: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String accessToken = dotenv.get('MAPBOX_ACCESS_TOKEN');

    // Centro iniziale
    LatLng initialCenter = _cachedPoints.isNotEmpty
        ? _cachedPoints.first
        : const LatLng(41.8719, 12.5674);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 6.0,
        // interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        // LAYER 1: SFONDO
        TileLayer(
          urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$accessToken",
          userAgentPackageName: 'com.heavyroute.app',
          // tileProvider: NetworkTileProvider(), // Default standard, più stabile
          retinaMode: true,
        ),

        // LAYER 2: LINEA
        if (_cachedPoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _cachedPoints,
                color: Colors.blueAccent,
                strokeWidth: 5.0,
                borderColor: Colors.blue[900]!, // Bordo scuro per contrasto
                borderStrokeWidth: 1.0,
              ),
            ],
          ),

        // LAYER 3: MARKER (Start/End)
        if (widget.route != null && widget.route!.startLat != null)
          MarkerLayer(
            markers: [
              // PARTENZA (Verde)
              Marker(
                point: LatLng(widget.route!.startLat!, widget.route!.startLon!),
                width: 60, height: 60,
                child: const Column(
                  children: [
                    Icon(Icons.trip_origin, color: Colors.green, size: 40),
                  ],
                ),
              ),
              // ARRIVO (Rosso)
              if (widget.route!.endLat != null && widget.route!.endLon != null)
                Marker(
                  point: LatLng(widget.route!.endLat!, widget.route!.endLon!),
                  width: 60, height: 60,
                  child: const Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 40),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}