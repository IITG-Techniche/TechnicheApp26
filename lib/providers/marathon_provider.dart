import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../model/marathon_models.dart';

import '../services/marathon_service.dart';
import '../services/foreground_task_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

// --- Services & Config ---
final marathonServiceProvider = Provider((ref) => MarathonService());

// We store the logged in username and category here. Empty means not enrolled.
final marathonUsernameProvider = StateProvider<String>((ref) => '');
final marathonCategoryProvider = StateProvider<String>((ref) => '6KM');

// Keys for SharedPreferences
const String _kMarathonUsername = 'marathon_username';
const String _kMarathonCategory = 'marathon_category';

/// Helper to save marathon enrollment data
Future<void> saveMarathonEnrollment(String username, String category) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kMarathonUsername, username);
  await prefs.setString(_kMarathonCategory, category);
}

/// Helper to clear marathon enrollment data
Future<void> clearMarathonEnrollment() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kMarathonUsername);
  await prefs.remove(_kMarathonCategory);
}

/// Helper to load marathon enrollment data and update providers
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

// --- Future Providers for Data Fetching ---
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

// --- Live Run Tracking State ---
class LiveRunState {
  final bool isRunning;
  final bool isPaused;
  final int stepCount;
  final double distanceKm;
  final int elapsedSeconds;
  final double currentPace; // Windowed pace (min/km)

  // Calculate overall average pace in min/km
  double get avgPace {
    if (distanceKm < 0.005) return 0.0;
    double minutes = elapsedSeconds / 60;
    if (minutes < 0.01) return 0.0;
    double pace = minutes / distanceKm;
    return pace;
  }

  LiveRunState({
    required this.isRunning,
    required this.isPaused,
    required this.stepCount,
    required this.distanceKm,
    required this.elapsedSeconds,
    this.currentPace = 0.0,
  });

  LiveRunState copyWith({
    bool? isRunning,
    bool? isPaused,
    int? stepCount,
    double? distanceKm,
    int? elapsedSeconds,
    double? currentPace,
  }) {
    return LiveRunState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      stepCount: stepCount ?? this.stepCount,
      distanceKm: distanceKm ?? this.distanceKm,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentPace: currentPace ?? this.currentPace,
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

class LiveRunNotifier extends StateNotifier<LiveRunState> {
  LiveRunNotifier() : super(LiveRunState.initial()) {
    _initForegroundTask();
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'marathon_tracking',
        channelName: 'Marathon Tracking',
        channelDescription: 'Running tracking notification',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 1000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    // Listen to data from the task
    FlutterForegroundTask.receivePort?.listen(_onReceiveTaskData);
  }

  SendPort? _taskSendPort;

  void _onReceiveTaskData(dynamic data) {
    if (data is SendPort) {
      _taskSendPort = data;
      return;
    }

    if (data is Map) {
      final elapsed = data['elapsedSeconds'] as int?;
      final steps = data['stepCount'] as int?;
      final dist = data['distanceKm'] as double?;
      final pace = data['currentPace'] as double?;

      if (elapsed != null && steps != null && dist != null) {
        state = state.copyWith(
          elapsedSeconds: elapsed,
          stepCount: steps,
          distanceKm: dist,
          currentPace: pace ?? 0.0,
        );
      }
    }
  }

  // Average stride length roughly 0.762 meters
  // final double _strideLengthKm = 0.000762; (now in handler)

  void startRun() async {
    // Check permissions
    try {
      // 1. Activity Recognition (Pedometer) Permission
      final activityStatus = await Permission.activityRecognition.status;
      if (activityStatus != PermissionStatus.granted) {
        await Permission.activityRecognition.request();
      }

      // 2. Battery Optimization
      // In release mode, requestIgnoreBatteryOptimization can sometimes cause issues if not handled carefully
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // 3. Notifications
      final NotificationPermission notificationPermissionStatus =
          await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermissionStatus != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      // We continue anyway as some permissions might be optional or already granted
    }

    state = LiveRunState.initial().copyWith(isRunning: true);

    await FlutterForegroundTask.startService(
      notificationTitle: 'Marathon Run Started',
      notificationText: 'Tracking your progress...',
      callback: startCallback,
    );
  }

  void _startTimer() {}

  void pauseRun() {
    state = state.copyWith(isPaused: true);
    _taskSendPort?.send({'action': 'pause'});
  }

  void resumeRun() {
    state = state.copyWith(isPaused: false);
    _taskSendPort?.send({'action': 'resume'});
  }

  void stopRun() async {
    await FlutterForegroundTask.stopService();
    state = state.copyWith(isRunning: false, isPaused: false, currentPace: 0.0);
  }

  void resetRun() {
    stopRun();
    state = LiveRunState.initial();
  }
}

final liveRunProvider =
    StateNotifierProvider<LiveRunNotifier, LiveRunState>((ref) {
  return LiveRunNotifier();
});
