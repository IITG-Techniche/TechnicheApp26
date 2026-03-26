import 'dart:async';
import 'dart:ui';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

const String _kPortName = 'marathon_gps_port';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyForegroundTaskHandler());
}

class MyForegroundTaskHandler extends TaskHandler {
  int _elapsedSeconds = 0;
  double _distanceKm = 0.0;
  bool _isPaused = false;

  // ── GPS (primary) ──────────────────────────────────────────────────────────
  StreamSubscription<Position>? _locationSubscription;
  Position? _lastPosition;
  DateTime? _lastPositionTime;
  bool _hasGpsFix = false;

  // ── EMA smoothing ─────────────────────────────────────────────────────────
  double? _smoothedLat;
  double? _smoothedLng;
  static const double _emaAlpha = 0.3; // Responsiveness vs smoothness tradeoff

  // ── Route tracking ─────────────────────────────────────────────────────────
  final List<Map<String, double>> _routePoints = [];
  int _lastSentRouteIndex = 0;

  // ── Pace calculation ───────────────────────────────────────────────────────
  final List<({int time, double dist})> _history = [];
  static const int _windowSeconds = 10;
  int _lastMovementTime = 0;

  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('MyForegroundTaskHandler onStart (v12 Filtered GPS)');
    _startLocationTracking();

    // Setup IsolateNameServer port
    final ReceivePort port = ReceivePort();
    IsolateNameServer.removePortNameMapping(_kPortName);
    IsolateNameServer.registerPortWithName(port.sendPort, _kPortName);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Handled by manual _tick() for better reliability on Android
  }

  void _tick() {
    print('Handler Tick: dist=$_distanceKm, fix=$_hasGpsFix');
    if (!_isPaused) {
      _elapsedSeconds++;
    }

    double currentPace = 0.0;
    try {
      if (!_isPaused && (_elapsedSeconds - _lastMovementTime <= 15)) {
        _history.add((time: _elapsedSeconds, dist: _distanceKm));
        _history.removeWhere((p) => p.time < _elapsedSeconds - _windowSeconds);

        if (_history.length >= 2) {
          final first = _history.first;
          final last = _history.last;
          final timeDiff = last.time - first.time;
          final distDiff = last.dist - first.dist;

          if (timeDiff > 0 && distDiff > 0.0001) {
            double minutes = timeDiff / 60.0;
            currentPace = minutes / distDiff;
            if (currentPace > 30) currentPace = 0.0;
          }
        }
      }
    } catch (e) {
      print('Error calculating pace: $e');
    }

    List<Map<String, double>> newPoints = [];
    if (_lastSentRouteIndex < _routePoints.length) {
      newPoints = _routePoints.sublist(_lastSentRouteIndex);
      _lastSentRouteIndex = _routePoints.length;
    }

    final String timeStr =
        '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:'
        '${(_elapsedSeconds % 60).toString().padLeft(2, '0')}';

    final String msg =
        '${_distanceKm.toStringAsFixed(2)} km | $timeStr | Pace: ${currentPace.toStringAsFixed(1)} min/km';

    FlutterForegroundTask.updateService(
      notificationTitle: _isPaused ? 'Run Paused' : 'Live Run Tracking',
      notificationText: msg,
    );

    final data = {
      'elapsedSeconds': _elapsedSeconds,
      'distanceKm': _distanceKm,
      'currentPace': currentPace,
      'currentHeading': _lastPosition?.heading,
      'isPaused': _isPaused,
      'hasGpsFix': _hasGpsFix,
      'newRoutePoints': newPoints,
    };

    // Explicitly send data to main isolate
    FlutterForegroundTask.sendDataToMain(data);

    // Bulletproof backup: Send via IsolateNameServer
    final SendPort? mainPort = IsolateNameServer.lookupPortByName(_kPortName);
    if (mainPort != null) {
      mainPort.send(data);
    } else {
      print('Handler Warning: No main port found via IsolateNameServer');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('MyForegroundTaskHandler onDestroy');
    IsolateNameServer.removePortNameMapping(_kPortName);
    _timer?.cancel();
    await _locationSubscription?.cancel();
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map) {
      if (data['action'] == 'pause') {
        _isPaused = true;
        _locationSubscription?.pause();
      } else if (data['action'] == 'resume') {
        _isPaused = false;
        _locationSubscription?.resume();
      }
    }
  }

  void _startLocationTracking() {
    print('Starting Filtered GPS tracking (v12)');
    try {
      _locationSubscription?.cancel();
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 3, // Update every 3 meters
        ),
      ).listen((Position position) {
        if (_isPaused) return;

        final now = DateTime.now();

        // ── Filter 1: Accuracy check (30m threshold) ──
        if (position.accuracy > 30.0) {
          print(
              'GPS Filter: Weak signal (${position.accuracy.toStringAsFixed(1)}m) — rejected');
          return;
        }

        // ── Filter 2: Minimum time delta (at least 1 second between points) ──
        if (_lastPositionTime != null &&
            now.difference(_lastPositionTime!).inMilliseconds < 1000) {
          return;
        }

        // ── Filter 3: Speed-based rejection ──
        if (_lastPosition != null && _lastPositionTime != null) {
          final double distMeters = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          final double timeDeltaSeconds =
              now.difference(_lastPositionTime!).inMilliseconds / 1000.0;

          if (timeDeltaSeconds > 0) {
            final double speedMs = distMeters / timeDeltaSeconds;
            // >12 m/s ≈ 43 km/h — impossible for running, reject
            if (speedMs > 12.0) {
              print(
                  'GPS Filter: Speed spike (${speedMs.toStringAsFixed(1)} m/s) — rejected');
              return;
            }
          }

          // ── Filter 4: Displacement bounds (same as before but tighter upper) ──
          // Movements <1m are jitter, >50m in one update are GPS teleports
          if (distMeters > 1.0 && distMeters < 50.0) {
            _distanceKm += distMeters / 1000.0;
            _lastMovementTime = _elapsedSeconds;
          }
        }

        // ── Filter 5: EMA smoothing on lat/lng ──
        double smoothLat, smoothLng;
        if (_smoothedLat == null || _smoothedLng == null) {
          smoothLat = position.latitude;
          smoothLng = position.longitude;
        } else {
          smoothLat =
              _emaAlpha * position.latitude + (1 - _emaAlpha) * _smoothedLat!;
          smoothLng =
              _emaAlpha * position.longitude + (1 - _emaAlpha) * _smoothedLng!;
        }
        _smoothedLat = smoothLat;
        _smoothedLng = smoothLng;

        _routePoints.add({
          'lat': smoothLat,
          'lng': smoothLng,
        });

        _lastPosition = position;
        _lastPositionTime = now;
        _hasGpsFix = true;

        print(
            'GPS: ${smoothLat.toStringAsFixed(5)}, ${smoothLng.toStringAsFixed(5)} | dist: ${_distanceKm.toStringAsFixed(3)} km');
      }, onError: (e) {
        print('Geolocator error: $e');
      });
    } catch (e) {
      print('Failed to start GPS tracking: $e');
    }
  }
}
