import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import '../../../constant/appTheme.dart';
import '../../../services/map_cache_service.dart';
import 'runner_marker.dart';

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

  /// true = map auto-rotates to match phone heading (direction-oriented)
  bool _compassLocked = true;

  /// Show the north-reset FAB only when user has manually rotated
  bool _showNorthButton = true;

  bool _hasCenteredOnFirstFix = false;

  /// Track whether rotation came from code (not user gesture)
  bool _programmaticRotation = false;

  static const LatLng _defaultCenter = LatLng(26.1445, 91.7362);
  static const double _defaultZoom = 18.0;

  @override
  void initState() {
    super.initState();
    final initialPos = widget.currentLocation ??
        (widget.routePoints.isNotEmpty ? widget.routePoints.last : null);
    if (initialPos != null) {
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

    final lastPoint = widget.currentLocation ??
        (widget.routePoints.isNotEmpty ? widget.routePoints.last : null);
    if (lastPoint == null) return;

    // Center on first GPS fix
    if (!_hasCenteredOnFirstFix && widget.hasGpsFix) {
      _hasCenteredOnFirstFix = true;
      _lastInteraction = null;
      _mapController.move(lastPoint, _defaultZoom);
    }

    // Proactive tile seeding if moved >500m
    if (_lastSeededLocation == null ||
        const Distance().as(LengthUnit.Meter, _lastSeededLocation!, lastPoint) >
            500) {
      _seedLoc(lastPoint);
    }

    // Auto-center: only if no recent user interaction (>5s)
    final shouldForceCenter = _lastInteraction == null ||
        DateTime.now().difference(_lastInteraction!).inSeconds > 5;
    if (shouldForceCenter) {
      _mapController.move(lastPoint, _mapController.camera.zoom);
    }

    // Compass-lock: auto-rotate map to phone heading
    if (_compassLocked && widget.currentHeading != null) {
      _programmaticRotation = true;
      _mapController.rotate(-(widget.currentHeading!));
    }
  }

  /// User pressed the north-up button
  void _resetToNorth() {
    setState(() {
      _programmaticRotation = true;
      _mapController.rotate(0);
      _compassLocked = false;
      _showNorthButton = false;
    });
  }

  /// User pressed the re-center / location button
  void _recenterAndLock() {
    final pos = widget.currentLocation ??
        (widget.routePoints.isNotEmpty
            ? widget.routePoints.last
            : _defaultCenter);
    setState(() {
      _lastInteraction = null;
      _compassLocked = true;
      _showNorthButton = false;
      _mapController.move(pos, _defaultZoom);
      // Immediately apply heading
      if (widget.currentHeading != null) {
        _programmaticRotation = true;
        _mapController.rotate(-(widget.currentHeading!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = widget.currentLocation ??
        (widget.routePoints.isNotEmpty
            ? widget.routePoints.last
            : _defaultCenter);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: currentPosition,
            initialZoom: _defaultZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onPointerDown: (_, __) {
              _lastInteraction = DateTime.now();
            },
            onMapEvent: (event) {
              if (event is MapEventMoveStart ||
                  event is MapEventFlingAnimation) {
                _lastInteraction = DateTime.now();
              }
              // Detect manual rotation by the user
              if (event is MapEventRotate) {
                if (_programmaticRotation) {
                  _programmaticRotation = false;
                } else {
                  // User manually rotated → break compass lock, show north FAB
                  if (_compassLocked || !_showNorthButton) {
                    setState(() {
                      _compassLocked = false;
                      _showNorthButton = true;
                    });
                  }
                }
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
              userAgentPackageName: 'com.techniche.techniche26',
              maxZoom: 20,
              keepBuffer: 8,
              panBuffer: 3,
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

        // ── North-up FAB (only visible after manual rotation) ──
        if (_showNorthButton)
          Positioned(
            right: 12,
            bottom: 60,
            child: GestureDetector(
              onTap: _resetToNorth,
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
                child: const Icon(
                  Icons.north,
                  color: Color(0xFF002661),
                  size: 22,
                ),
              ),
            ),
          ),

        // ── Re-center + direction lock button (always visible) ──
        Positioned(
          right: 12,
          bottom: 12,
          child: GestureDetector(
            onTap: _recenterAndLock,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _compassLocked ? const Color(0xFF002661) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Icons.my_location,
                color: _compassLocked ? Colors.white : const Color(0xFF002661),
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
