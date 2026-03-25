import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import '../../../constant/appTheme.dart';
import '../../../services/map_cache_service.dart';
import 'runner_marker.dart';

/// A live map widget that shows the runner's route as a polyline and
/// their current position as an animated marker.
class LiveRunMap extends StatefulWidget {
  final List<LatLng> routePoints;
  final LatLng? currentLocation;
  final bool hasGpsFix;
  final bool isRunning;
  final double? currentHeading;

  const LiveRunMap({
    super.key,
    required this.routePoints,
    this.currentLocation,
    required this.hasGpsFix,
    required this.isRunning,
    this.currentHeading,
  });

  @override
  State<LiveRunMap> createState() => _LiveRunMapState();
}

class _LiveRunMapState extends State<LiveRunMap> {
  final MapController _mapController = MapController();
  DateTime? _lastInteraction;
  LatLng? _lastSeededLocation;
  bool _initialized = false;

  // Default center: IIT Guwahati campus
  static const LatLng _defaultCenter = LatLng(26.1445, 91.7362);

  @override
  void initState() {
    super.initState();
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    await MapCacheService.init();
    if (mounted) {
      setState(() {
        _initialized = true;
      });
      final initialPos = widget.currentLocation ?? (widget.routePoints.isNotEmpty
          ? widget.routePoints.last
          : _defaultCenter);
      _seedLoc(initialPos);
    }
  }


  void _seedLoc(LatLng loc) {
    MapCacheService.seedArea(loc);
    _lastSeededLocation = loc;
  }

  @override
  void didUpdateWidget(covariant LiveRunMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final lastPoint = widget.currentLocation ?? (widget.routePoints.isNotEmpty ? widget.routePoints.last : null);
    if (lastPoint != null) {
      // 1. Proactive Seeding (1km radius) if moved substantially (>500m)
      if (_lastSeededLocation == null ||
          Distance().as(LengthUnit.Meter, _lastSeededLocation!, lastPoint) >
              500) {
        _seedLoc(lastPoint);
      }

      // 2. Auto-center logic
      // Only auto-center if there has been NO interaction recently (> 5 seconds)
      final shouldForceCenter = _lastInteraction == null ||
          DateTime.now().difference(_lastInteraction!).inSeconds > 5;

      if (shouldForceCenter) {
        _mapController.move(lastPoint, _mapController.camera.zoom);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = widget.currentLocation ?? (widget.routePoints.isNotEmpty
        ? widget.routePoints.last
        : _defaultCenter);

    return Stack(
      children: [
        if (!_initialized)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
        if (_initialized)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition,
              initialZoom: 16.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onPointerDown: (_, __) {
                _lastInteraction = DateTime.now();
              },
              onPointerCancel: (_, __) {
                _lastInteraction = DateTime.now();
              },
              onMapEvent: (event) {
                if (event is MapEventMoveStart || event is MapEventFlingAnimation) {
                  _lastInteraction = DateTime.now();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.techniche.techniche26',
                maxZoom: 20,
                tileDisplay: const TileDisplay.fadeIn(),
                tileProvider: CachedTileProvider(
                  store: MapCacheService.cacheStore,
                ),
              ),
              if (widget.routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.routePoints,
                      color: AppTheme.primaryBlue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              if (widget.currentLocation != null || widget.routePoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPosition,
                      width: 40,
                      height: 40,
                      child: RunnerMarker(heading: widget.currentHeading),
                    ),
                  ],
                ),
            ],
          ),
        // Re-center button (Always visible for easy location finding)
        if (_initialized)
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: () {
                _lastInteraction = null; // Clear to allow immediate re-centering logic
                _mapController.move(currentPosition, 16.5);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.my_location, color: Color(0xFF002661)),
              ),
            ),
          ),
      ],
    );
  }
}
