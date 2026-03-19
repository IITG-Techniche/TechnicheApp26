import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/marathon_models.dart';
import '../services/marathon_service.dart';
import '../services/foreground_task_handler.dart';

// ════════════════════════════════════════════════════════════════════════════
// 1. SERVICE PROVIDER
// ════════════════════════════════════════════════════════════════════════════

final marathonServiceProvider = Provider((ref) => MarathonService());

// ════════════════════════════════════════════════════════════════════════════
// 2. SIMPLE STATE PROVIDERS
// ════════════════════════════════════════════════════════════════════════════

final marathonUsernameProvider = StateProvider<String>((ref) => '');
final marathonCategoryProvider = StateProvider<String>((ref) => '6KM');

// ════════════════════════════════════════════════════════════════════════════
// 3. SHARED PREFERENCES HELPERS
// ════════════════════════════════════════════════════════════════════════════

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

// ════════════════════════════════════════════════════════════════════════════
// 4. ASYNC DATA PROVIDERS
// ════════════════════════════════════════════════════════════════════════════

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

// ════════════════════════════════════════════════════════════════════════════
// 5. LIVE RUN STATE
// ════════════════════════════════════════════════════════════════════════════

class LiveRunState {
  final bool isRunning;
  final bool isPaused;
  final int stepCount;
  final double distanceKm;
  final int elapsedSeconds;
  final double currentPace;
  final bool isSaving;
  final String? errorMessage;

  LiveRunState({
    required this.isRunning,
    required this.isPaused,
    required this.stepCount,
    required this.distanceKm,
    required this.elapsedSeconds,
    this.currentPace = 0.0,
    this.isSaving = false,
    this.errorMessage,
  });

  double get avgPace {
    if (distanceKm < 0.005) return 0.0;
    double minutes = elapsedSeconds / 60;
    if (minutes < 0.01) return 0.0;
    return minutes / distanceKm;
  }

  int get calories => (stepCount * 0.04).toInt();

  LiveRunState copyWith({
    bool? isRunning,
    bool? isPaused,
    int? stepCount,
    double? distanceKm,
    int? elapsedSeconds,
    double? currentPace,
    bool? isSaving,
    String? errorMessage,
  }) {
    return LiveRunState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      stepCount: stepCount ?? this.stepCount,
      distanceKm: distanceKm ?? this.distanceKm,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentPace: currentPace ?? this.currentPace,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }

  factory LiveRunState.initial() => LiveRunState(
    isRunning: false,
    isPaused: false,
    stepCount: 0,
    distanceKm: 0.0,
    elapsedSeconds: 0,
  );
}

// ════════════════════════════════════════════════════════════════════════════
// 6. LIVE RUN NOTIFIER
// ════════════════════════════════════════════════════════════════════════════

class LiveRunNotifier extends StateNotifier<LiveRunState> {
  LiveRunNotifier(this._ref) : super(LiveRunState.initial()) {
    _initForegroundTask();
  }

  final Ref _ref;
  SendPort? _taskSendPort;

  // ── v8 compatible init ────────────────────────────────────────────────────
  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'marathon_tracking',
        channelName: 'Marathon Tracking',
        channelDescription: 'Running tracking notification',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        // iconData removed — v8 uses launcher icon automatically
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // interval + isOnceEvent replaced by eventAction in v8
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    FlutterForegroundTask.receivePort?.listen(_onReceiveTaskData);
  }

  void _onReceiveTaskData(dynamic data) {
    if (data is SendPort) {
      _taskSendPort = data;
      return;
    }

    if (data is Map) {
      final elapsed = data['elapsedSeconds'] as int?;
      final steps   = data['stepCount']      as int?;
      final dist    = data['distanceKm']     as double?;
      final pace    = data['currentPace']    as double?;

      if (elapsed != null && steps != null && dist != null) {
        state = state.copyWith(
          elapsedSeconds: elapsed,
          stepCount:      steps,
          distanceKm:     dist,
          currentPace:    pace ?? 0.0,
        );
      }
    }
  }

  Future<void> startRun() async {
    final username = _ref.read(marathonUsernameProvider);
    if (username.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enroll first.');
      return;
    }

    try {
      final activityStatus = await Permission.activityRecognition.status;
      if (activityStatus != PermissionStatus.granted) {
        await Permission.activityRecognition.request();
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
      isRunning:    true,
      errorMessage: null,
    );

    await FlutterForegroundTask.startService(
      notificationTitle: 'Marathon Run Started',
      notificationText:  'Tracking your progress...',
      callback:          startCallback,
    );
  }

  void pauseRun() {
    if (!state.isRunning || state.isPaused) return;
    state = state.copyWith(isPaused: true);
    _taskSendPort?.send({'action': 'pause'});
  }

  void resumeRun() {
    if (!state.isRunning || !state.isPaused) return;
    state = state.copyWith(isPaused: false);
    _taskSendPort?.send({'action': 'resume'});
  }

  Future<void> stopRun() async {
    if (!state.isRunning) return;

    await FlutterForegroundTask.stopService();

    final snapshotDistance = state.distanceKm;
    final snapshotSeconds  = state.elapsedSeconds;
    final snapshotSteps    = state.stepCount;
    final snapshotCalories = state.calories;
    final snapshotAvgPace  = state.avgPace;

    state = state.copyWith(
      isRunning:   false,
      isPaused:    false,
      currentPace: 0.0,
      isSaving:    true,
    );

    try {
      final username = _ref.read(marathonUsernameProvider);
      final category = _ref.read(marathonCategoryProvider);
      final service  = _ref.read(marathonServiceProvider);

      final durationMinutes = snapshotSeconds / 60.0;

      final log = PracticeLog(
        id:              '',
        username:        username,
        distanceKm:      snapshotDistance,
        durationMinutes: durationMinutes,
        avgPace:         snapshotAvgPace,
        stepCount:       snapshotSteps,
        calories:        snapshotCalories,
        category:        category,
        createdAt:       DateTime.now(),
      );

      await service.saveRun(log);

      _ref.invalidate(recentRunsProvider);
      _ref.invalidate(allRunsProvider);
      _ref.invalidate(progressStatsProvider);
      _ref.invalidate(distanceLeaderboardProvider);
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

// ════════════════════════════════════════════════════════════════════════════
// 7. PROVIDER
// ════════════════════════════════════════════════════════════════════════════

final liveRunProvider =
StateNotifierProvider<LiveRunNotifier, LiveRunState>((ref) {
  return LiveRunNotifier(ref);
});