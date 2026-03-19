import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyForegroundTaskHandler());
}

class MyForegroundTaskHandler extends TaskHandler {
  int _elapsedSeconds = 0;
  int _stepCount = 0;
  double _distanceKm = 0.0;
  int _initialStepCount = -1;
  int _baseSteps = 0;

  // Pace calculation
  int _lastStepCount = 0;
  int _lastStepTime = 0;
  final List<({int time, double dist})> _history = [];
  static const int _windowSeconds = 10;

  final double _strideLengthKm = 0.000762;

  StreamSubscription<StepCount>? _stepSubscription;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // In newer versions, we use specialized methods to listen for data from main
    // instead of manually managing a ReceivePort in some cases,
    // but the handler still supports receiving data via onReceiveData.

    _startStepTracking();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _elapsedSeconds++;

    // Calculate windowed pace
    double currentPace = 0.0;
    if (_elapsedSeconds - _lastStepTime <= 3) {
      _history.add((time: _elapsedSeconds, dist: _distanceKm));
      _history.removeWhere((p) => p.time < _elapsedSeconds - _windowSeconds);

      if (_history.length >= 2) {
        final first = _history.first;
        final last = _history.last;
        final timeDiff = last.time - first.time;
        final distDiff = last.dist - first.dist;

        if (timeDiff > 0 && distDiff > 0.0002) {
          double minutes = timeDiff / 60.0;
          currentPace = minutes / distDiff;
          if (currentPace > 30) currentPace = 0.0;
        }
      }
    }

    // Update notification
    FlutterForegroundTask.updateService(
      notificationTitle: 'Run in Progress',
      notificationText:
      '${_distanceKm.toStringAsFixed(2)} km | ${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')} | $_stepCount steps',
    );

    // Send data to the main isolate using the built-in static method
    FlutterForegroundTask.sendDataToMain({
      'elapsedSeconds': _elapsedSeconds,
      'stepCount': _stepCount,
      'distanceKm': _distanceKm,
      'currentPace': currentPace,
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await _stepSubscription?.cancel();
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  // Use this method to handle messages sent FROM the main UI to this Isolate
  @override
  void onReceiveData(Object data) {
    if (data is Map) {
      if (data['action'] == 'pause') {
        _stepSubscription?.cancel();
        _stepSubscription = null;
        _initialStepCount = -1;
      } else if (data['action'] == 'resume') {
        _baseSteps = _stepCount;
        _startStepTracking();
      }
    }
  }

  void _startStepTracking() {
    _stepSubscription?.cancel();
    _stepSubscription = Pedometer.stepCountStream.listen((event) {
      if (_initialStepCount == -1) {
        _initialStepCount = event.steps;
        return;
      }

      int deltaSteps = event.steps - _initialStepCount;
      if (deltaSteps < 0) deltaSteps = 0;

      _stepCount = _baseSteps + deltaSteps;
      _distanceKm = _stepCount * _strideLengthKm;

      if (_stepCount > _lastStepCount) {
        _lastStepTime = _elapsedSeconds;
        _lastStepCount = _stepCount;
      }
    });
  }
}