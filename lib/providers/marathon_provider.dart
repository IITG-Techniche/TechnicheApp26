import 'dart:async';
import 'dart:ui';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/marathon_models.dart';
import '../services/marathon_service.dart';
import '../services/foreground_task_handler.dart';
import '../services/local_db_service.dart';

const String _kPortName = 'marathon_gps_port';

final marathonServiceProvider = Provider((ref) => MarathonService());
final localDbServiceProvider = Provider((ref) => LocalDbService());

final marathonUsernameProvider = StateProvider<String>((ref) => '');
final marathonCategoryProvider = StateProvider<String>((ref) => '6KM');

const String _kMarathonUsername = 'marathon_username';
const String _kMarathonCategory = 'marathon_category';

Future<void> saveMarathonEnrollment(String username, String category) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kMarathonUsername, username);
  await prefs.setString(_kMarathonCategory, category);
}

Future<void> clearMarathonEnrollment() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kMarathonUsername);
  await prefs.remove(_kMarathonCategory);
}

Future<void> loadMarathonEnrollment(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString(_kMarathonUsername);
  final category = prefs.getString(_kMarathonCategory);

  if (username != null && username.isNotEmpty) {
    ref.read(marathonUsernameProvider.notifier).state = username;
  }
  if (category != null && category.isNotEmpty) {
    ref.read(marathonCategoryProvider.notifier).state = category;
  }
}

final distanceLeaderboardProvider =
    FutureProvider.autoDispose<List<DistanceLeaderboardEntry>>((ref) async {
  final service = ref.watch(marathonServiceProvider);
  final category = ref.watch(marathonCategoryProvider);
  return service.getDistanceLeaderboard(category);
});

final progressStatsProvider =
    FutureProvider.autoDispose<ProgressStats>((ref) async {
  final service = ref.watch(marathonServiceProvider);
  final username = ref.watch(marathonUsernameProvider);
  if (username.isEmpty) return ProgressStats.empty();
  return service.getUserProgress(username);
});

final recentRunsProvider =
    FutureProvider.autoDispose<List<PracticeLog>>((ref) async {
  final service = ref.watch(marathonServiceProvider);
  final username = ref.watch(marathonUsernameProvider);
  if (username.isEmpty) return [];
  return service.getRecentRuns(username);
});

final allRunsProvider =
    FutureProvider.autoDispose<List<PracticeLog>>((ref) async {
  final service = ref.watch(marathonServiceProvider);
  final username = ref.watch(marathonUsernameProvider);
  if (username.isEmpty) return [];
  return service.getAllRuns(username);
});

class LiveRunState {
  final bool isRunning;
  final bool isPaused;
  final double distanceKm;
  final int elapsedSeconds;
  final double currentPace;
  final double? currentHeading; // User's orientation
  final bool isSaving;
  final String? errorMessage;
  final List<LatLng> routePoints;
  final bool hasGpsFix;

  LiveRunState({
    required this.isRunning,
    required this.isPaused,
    required this.distanceKm,
    required this.elapsedSeconds,
    this.currentPace = 0.0,
    this.currentHeading,
    this.isSaving = false,
    this.errorMessage,
    this.routePoints = const [],
    this.hasGpsFix = false,
  });

  double get avgSpeed {
    if (elapsedSeconds < 2 || distanceKm < 0.001) return 0.0;
    return (distanceKm / (elapsedSeconds / 3600.0));
  }

  int get calories => (distanceKm * 60).toInt();

  LiveRunState copyWith({
    bool? isRunning,
    bool? isPaused,
    double? distanceKm,
    int? elapsedSeconds,
    double? currentPace,
    double? currentHeading,
    bool? isSaving,
    String? errorMessage,
    List<LatLng>? routePoints,
    bool? hasGpsFix,
  }) {
    return LiveRunState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      distanceKm: distanceKm ?? this.distanceKm,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentPace: currentPace ?? this.currentPace,
      currentHeading: currentHeading ?? this.currentHeading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      routePoints: routePoints ?? this.routePoints,
      hasGpsFix: hasGpsFix ?? this.hasGpsFix,
    );
  }

  factory LiveRunState.initial() => LiveRunState(
        isRunning: false,
        isPaused: false,
        distanceKm: 0.0,
        elapsedSeconds: 0,
        routePoints: [],
        hasGpsFix: false,
      );
}

final _liveRunDataController = StreamController<dynamic>.broadcast();

@pragma('vm:entry-point')
void _globalTaskDataCallback(dynamic data) {
  debugPrint('GLOBAL DATA DISPATCHER: $data');
  _liveRunDataController.add(data);
}

class LiveRunNotifier extends StateNotifier<LiveRunState> {
  final Ref _ref;
  StreamSubscription? _dataSubscription;
  Timer? _uiTimer;
  StreamSubscription<Position>? _uiLocationSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  static ReceivePort? _staticPort;

  LiveRunNotifier(this._ref) : super(LiveRunState.initial()) {
    debugPrint('LiveRunNotifier initialized.');
    _initForegroundTask();
    _dataSubscription =
        _liveRunDataController.stream.listen(_onReceiveTaskData);
    _setupBulletproofPort();

    // START PREVIEW TRACKING (Orientation + Location before START is clicked)
    _startPreviewTracking();
  }

  Future<void> _startPreviewTracking() async {
    // 0. Ensure permissions for sensors/location are requested
    try {
      if (!await Permission.sensors.isGranted) {
        await Permission.sensors.request();
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        // Location is often needed for compass on Android
        await Geolocator.requestPermission();
      }
    } catch (_) {}

    // 1. Instant Compass for the arrow
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted) {
        state = state.copyWith(
            currentHeading: event.heading ?? event.headingForCameraMode);
      }
    });

    // 2. Low-frequency location for the preview dot
    _uiLocationSubscription?.cancel();
    _uiLocationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 3,
      ),
    ).listen((Position pos) {
      if (mounted && !state.isRunning) {
        state = state.copyWith(
          routePoints: [LatLng(pos.latitude, pos.longitude)],
          hasGpsFix: true,
          currentHeading: pos.heading,
        );
      }
    });
  }

  void _setupBulletproofPort() {
    if (_staticPort != null) return; // Only register once

    _staticPort = ReceivePort();
    IsolateNameServer.removePortNameMapping(_kPortName);
    IsolateNameServer.registerPortWithName(_staticPort!.sendPort, _kPortName);

    _staticPort!.listen((data) {
      debugPrint('BULLETPROOF PORT DATA: $data');
      _onReceiveTaskData(data);
    });
    debugPrint('Bulletproof port registered with name: $_kPortName');
  }

  Future<void> _initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'marathon_tracking',
        channelName: 'Marathon Tracking',
        channelDescription: 'Running tracking notification',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    FlutterForegroundTask.addTaskDataCallback(_globalTaskDataCallback);

    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      state = state.copyWith(isRunning: true);
    }
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _uiLocationSubscription?.cancel();
    _compassSubscription?.cancel();
    _uiTimer?.cancel();
    super.dispose();
  }

  void _onReceiveTaskData(dynamic data) {
    if (data is Map) {
      final elapsed = data['elapsedSeconds'] is num
          ? (data['elapsedSeconds'] as num).toInt()
          : null;
      final dist = data['distanceKm'] is num
          ? (data['distanceKm'] as num).toDouble()
          : null;
      final pace = data['currentPace'] is num
          ? (data['currentPace'] as num).toDouble()
          : null;
      final heading = data['currentHeading'] is num
          ? (data['currentHeading'] as num).toDouble()
          : null;
      final isPaused = data['isPaused'] as bool?;
      final hasGpsFix = data['hasGpsFix'] as bool?;

      List<LatLng> newPoints = [];
      if (data['newRoutePoints'] != null) {
        final rawPoints = data['newRoutePoints'] as List;
        for (final p in rawPoints) {
          if (p is Map) {
            final lat = p['lat'] is num ? (p['lat'] as num).toDouble() : null;
            final lng = p['lng'] is num ? (p['lng'] as num).toDouble() : null;
            if (lat != null && lng != null) {
              newPoints.add(LatLng(lat, lng));
            }
          }
        }
      }

      if (elapsed != null && dist != null) {
        if (newPoints.isNotEmpty) {
          _ref.read(localDbServiceProvider).insertRoutePoints(newPoints);
        }

        final updatedRoute = [...state.routePoints, ...newPoints];

        // Use background source of truth for total distance
        state = state.copyWith(
          elapsedSeconds: (elapsed - state.elapsedSeconds).abs() > 3
              ? elapsed
              : state.elapsedSeconds,
          distanceKm: dist,
          currentPace: pace ?? state.currentPace,
          currentHeading: heading ?? state.currentHeading,
          isPaused: isPaused ?? state.isPaused,
          isRunning: true,
          errorMessage: null,
          routePoints: updatedRoute,
          hasGpsFix: hasGpsFix ?? state.hasGpsFix,
        );
      }
    }
  }

  void _startUiGpsTracking() {
    _uiLocationSubscription?.cancel();

    // Compass for stationary orientation
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (state.isRunning && !state.isPaused) {
        state = state.copyWith(currentHeading: event.heading);
      }
    });

    _uiLocationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 3,
      ),
    ).listen((Position position) {
      if (state.isRunning && !state.isPaused) {
        final newPoint = LatLng(position.latitude, position.longitude);

        // Add point to UI route immediately
        final updatedRoute = [...state.routePoints, newPoint];

        // Calculate incremental distance locally for smooth UI updates
        double addedDist = 0.0;
        if (state.routePoints.isNotEmpty) {
          addedDist = Geolocator.distanceBetween(
                state.routePoints.last.latitude,
                state.routePoints.last.longitude,
                position.latitude,
                position.longitude,
              ) /
              1000.0;
        }

        // Only add significant movement (> 1m) to avoid GPS jitter at static location
        if (addedDist > 0.001 || state.routePoints.isEmpty) {
          state = state.copyWith(
            routePoints: updatedRoute,
            currentHeading: position.heading,
            hasGpsFix: true,
            distanceKm: state.distanceKm + addedDist,
          );

          // Also save to local SQLite for safety
          _ref.read(localDbServiceProvider).insertRoutePoints([newPoint]);
        }
      }
    });
  }

  void _startUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isRunning && !state.isPaused) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  Future<void> startRun() async {
    // Clear any abandoned route points from a previous crash/run
    await _ref.read(localDbServiceProvider).clearRoutePoints();

    final username = _ref.read(marathonUsernameProvider);
    if (username.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enroll first.');
      return;
    }

    try {
      // 1. Check if GPS is enabled on the device
      if (!await Geolocator.isLocationServiceEnabled()) {
        state = state.copyWith(
            errorMessage:
                'Please enable GPS/Location services on your device.');
        return;
      }

      // 2. Activity Recognition
      if (!await Permission.activityRecognition.isGranted) {
        final status = await Permission.activityRecognition.request();
        if (!status.isGranted) {
          state = state.copyWith(
              errorMessage: 'Activity Recognition permission is required.');
          return;
        }
      }

      // 3. Location
      if (!await Permission.location.isGranted) {
        final status = await Permission.location.request();
        if (!status.isGranted) {
          state = state.copyWith(
              errorMessage:
                  'Location permission is required for accurate tracking.');
          return;
        }
      }

      // 4. Background Location (Best effort for Android 10+)
      if (await Permission.location.isGranted) {
        if (!await Permission.locationAlways.isGranted) {
          await Permission.locationAlways.request();
        }
      }

      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      final NotificationPermission notificationPermissionStatus =
          await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermissionStatus != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }

    state = LiveRunState.initial().copyWith(
      isRunning: true,
      errorMessage: null,
    );

    _startUiTimer();
    _startUiGpsTracking();

    await FlutterForegroundTask.startService(
      notificationTitle: 'Marathon Run Started',
      notificationText: 'Acquiring GPS signal...',
      callback: startCallback,
    );
  }

  void pauseRun() {
    if (!state.isRunning || state.isPaused) return;
    state = state.copyWith(isPaused: true);
    FlutterForegroundTask.sendDataToTask({'action': 'pause'});
  }

  void resumeRun() {
    if (!state.isRunning || !state.isPaused) return;
    state = state.copyWith(isPaused: false);
    FlutterForegroundTask.sendDataToTask({'action': 'resume'});
  }

  Future<void> stopRun() async {
    // Always try to stop service if it's running
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }

    if (!state.isRunning && !state.isSaving) return;

    final snapshotDistance = state.distanceKm;
    final snapshotSeconds = state.elapsedSeconds;
    final snapshotCalories = state.calories;
    final snapshotAvgSpeed = state.avgSpeed;
    // Read the complete route from local SQLite before syncing
    final snapshotRoutePoints =
        await _ref.read(localDbServiceProvider).getRoutePoints();

    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      currentPace: 0.0,
      isSaving: true,
    );
    _uiTimer?.cancel();
    _uiLocationSubscription?.cancel();

    try {
      final username = _ref.read(marathonUsernameProvider);
      final category = _ref.read(marathonCategoryProvider);
      final service = _ref.read(marathonServiceProvider);

      final durationMinutes = snapshotSeconds / 60.0;

      // Only save if there's significant data
      if (snapshotDistance > 0.001) {
        // Convert route points to serializable format
        final routeData = snapshotRoutePoints
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList();

        final log = PracticeLog(
          id: '',
          username: username,
          distanceKm: snapshotDistance,
          durationMinutes: durationMinutes,
          avgSpeed: snapshotAvgSpeed,
          stepCount: 0,
          calories: snapshotCalories,
          category: category,
          createdAt: DateTime.now(),
          routePoints: routeData,
        );

        await service.saveRun(log);

        _ref.invalidate(recentRunsProvider);
        _ref.invalidate(allRunsProvider);
        _ref.invalidate(progressStatsProvider);
        _ref.invalidate(distanceLeaderboardProvider);

        // Clear local storage after successful sync
        await _ref.read(localDbServiceProvider).clearRoutePoints();
      }
    } catch (e) {
      debugPrint('stopRun save error: $e');
      state = state.copyWith(errorMessage: 'Failed to save run: $e');
    }

    state = LiveRunState.initial();
  }

  void resetRun() {
    stopRun();
    state = LiveRunState.initial();
  }
}

final liveRunProvider =
    StateNotifierProvider<LiveRunNotifier, LiveRunState>((ref) {
  return LiveRunNotifier(ref);
});
