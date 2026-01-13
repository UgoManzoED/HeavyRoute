import 'dart:async';
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
  Timer? _zoomTimer;

  @override
  void didUpdateWidget(covariant HeavyRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.route?.polyline != _lastPolyline) {
      _processRoute();
    }
  }

  @override
  void dispose() {
    _zoomTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _processRoute();
  }

  void _processRoute() {
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
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> result = polylinePoints.decodePolyline(widget.route!.polyline);

      final points = result
          .map((p) => LatLng(p.latitude, p.longitude))
          .where((p) => !p.latitude.isNaN && !p.longitude.isNaN)
          .toList();

      if (mounted) {
        setState(() {
          _cachedPoints = points;
        });
      }

      if (points.isNotEmpty) {
        _zoomTimer?.cancel();
        _zoomTimer = Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            _safeZoomToFit(points);
          }
        });
      }
    } catch (e) {
      debugPrint("⚠️ Errore decodifica mappa: $e");
    }
  }

  /// Metodo per lo zoom
  void _safeZoomToFit(List<LatLng> points) {
    try {
      if (points.isEmpty) return;

      double minLat = 90.0, maxLat = -90.0, minLon = 180.0, maxLon = -180.0;
      for (var p in points) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLon) minLon = p.longitude;
        if (p.longitude > maxLon) maxLon = p.longitude;
      }

      if (minLat == 90.0) return;

      final double latDiff = (maxLat - minLat).abs();
      final double lonDiff = (maxLon - minLon).abs();

      if (latDiff < 0.0001 && lonDiff < 0.0001) {
        _mapController.move(LatLng(minLat, minLon), 14.0);
      } else {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon)),
            padding: const EdgeInsets.all(60),
            maxZoom: 14.0,
          ),
        );
      }
    } catch (e) {
      debugPrint("⚠️ Errore Zoom Safe: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String accessToken = dotenv.get('MAPBOX_ACCESS_TOKEN');

    LatLng initialCenter = _cachedPoints.isNotEmpty
        ? _cachedPoints.first
        : const LatLng(41.8719, 12.5674);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 6.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}?access_token=$accessToken",
          userAgentPackageName: 'com.heavyroute.app',

          tileProvider: NetworkTileProvider(),

          retinaMode: false,

          evictErrorTileStrategy: EvictErrorTileStrategy.none,
          errorImage: const NetworkImage('https://placehold.co/256x256/png?text=Mappa'),
        ),

        if (_cachedPoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _cachedPoints,
                color: Colors.blueAccent,
                strokeWidth: 5.0,
                borderColor: Colors.blue[900]!,
                borderStrokeWidth: 1.0,
              ),
            ],
          ),

        if (widget.route != null && widget.route!.startLat != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.route!.startLat!, widget.route!.startLon!),
                width: 60, height: 60,
                child: const Icon(Icons.trip_origin, color: Colors.green, size: 40),
              ),
              if (widget.route!.endLat != null)
                Marker(
                  point: LatLng(widget.route!.endLat!, widget.route!.endLon!),
                  width: 60, height: 60,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
            ],
          ),
      ],
    );
  }
}