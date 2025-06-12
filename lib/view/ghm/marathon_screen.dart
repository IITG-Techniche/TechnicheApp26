import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class MarathonScreen extends StatefulWidget {
  static const String routeName = '/ghm-screen';

  const MarathonScreen({Key? key}) : super(key: key);

  @override
  State<MarathonScreen> createState() => _MarathonScreenState();
}

class _MarathonScreenState extends State<MarathonScreen>
    with WidgetsBindingObserver {
  // Pedometer variables
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'Stopped';
  int _steps = 0;
  int _initialSteps = 0; // To keep track of steps at session start
  bool _isSessionActive = false;

  // Add this variable to track the current system step count
  int _currentSystemSteps = 0;

  // Activity calculation variables
  double _distance = 0.0; // in kilometers
  double _calories = 0.0;
  double _averageSpeed = 0.0; // in km/h
  double _stepsPerKm = 1300; // Average steps per km (can be adjusted)
  double _caloriesPerStep = 0.04; // Average calories per step

  // Theme colors (override for dark/futuristic look)
  final Color primaryColor = const Color(0xFF23242B); // Futuristic dark
  final Color accentColor = Colors.blueAccent;
  final Color lightColor = const Color(0xFF23242B);
  final Color backgroundColor = const Color(0xFF181A20);
  final Color textColor = Colors.white;

  // Timer for periodic updates
  Timer? _timer;
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;

  int _systemStepCountAtStart = 0;
  int _sessionSteps = 0;
  DateTime? _lastStepUpdate;

  // Session results
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();

    // Use a less frequent timer to reduce UI updates
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_startTime != null && _isSessionActive) {
        final newElapsedTime = DateTime.now().difference(_startTime!);
        // Only update if elapsed time changed by at least one second
        if (newElapsedTime.inSeconds != _elapsedTime.inSeconds) {
          setState(() {
            _elapsedTime = newElapsedTime;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestPermissions();
    }
  }

  void _requestPermissions() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _initPedometer();
    } else {
      setState(() {
        _status = 'Permission denied';
      });
    }
  }

  void _initPedometer() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    _pedestrianStatusStream.listen(
      _onPedestrianStatusChanged,
      onError: _onPedestrianStatusError,
    );

    _stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void _onPedestrianStatusError(error) {
    setState(() {
      _status = 'Pedestrian Status Error: $error';
    });
  }

  void _onStepCount(StepCount event) {
    // When initially receiving step count, just store the current system count
    // but don't display it until session starts
    if (!_isSessionActive) {
      _currentSystemSteps = event.steps;
      return;
    }

    // Only calculate steps if session is active
    int newSteps = event.steps - _initialSteps;

    // Only trigger a rebuild if the steps have changed significantly
    if (newSteps != _steps) {
      setState(() {
        _currentSystemSteps = event.steps;
        _steps = newSteps;

        // Only recalculate metrics if session is active
        _updateCalculations();
      });
    } else {
      // Update values without rebuilding the UI
      _currentSystemSteps = event.steps;
    }
  }

  void _onStepCountError(error) {
    setState(() {
      _steps = 0;
    });
  }

  // Optimize calculations to avoid redundant work
  void _updateCalculations() {
    // Only update calculations if we have actual steps
    if (_steps > 0) {
      _distance = _steps / _stepsPerKm;
      _calories = _steps * _caloriesPerStep;

      // Calculate speed only if we have elapsed time
      if (_elapsedTime.inSeconds > 0) {
        double hours = _elapsedTime.inSeconds / 3600;
        _averageSpeed = _distance / hours;
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _startSession() {
    // Only do something if not already active
    if (!_isSessionActive) {
      setState(() {
        _isSessionActive = true;
        _initialSteps =
            _currentSystemSteps; // Use current system count as baseline
        _steps = 0; // Reset session step count
        _distance = 0.0;
        _calories = 0.0;
        _startTime = DateTime.now();
        _elapsedTime = Duration.zero;
        _showResults = false;
      });
    }
  }

  void _stopSession() {
    // Only do something if active
    if (_isSessionActive) {
      setState(() {
        _isSessionActive = false;
        _showResults = true;
        // Final calculations for averages
        _updateCalculations();
      });
    }
  }

  void _resetPedometer() {
    setState(() {
      _isSessionActive = false;
      _initialSteps =
          _currentSystemSteps; // Set the current step count as the new baseline
      _steps = 0;
      _distance = 0.0;
      _calories = 0.0;
      _elapsedTime = Duration.zero;
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: backgroundColor,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: primaryColor,
        title: const Text(
          'GHM: Steps Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with activity status
            StatusHeader(
              status: _isSessionActive ? _status : 'Ready',
              isActive: _isSessionActive,
              primaryColor: accentColor,
            ),
            // Main metrics display
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Steps counter - primary metric
                    StepCounter(
                      steps: _steps,
                      primaryColor: accentColor,
                      lightColor: lightColor,
                      isActive: _isSessionActive,
                    ),
                    const SizedBox(height: 30),
                    // Session results (average speed) - shown only after session ends
                    if (_showResults)
                      SessionResultCard(
                        averageSpeed: _averageSpeed,
                        accentColor: accentColor,
                        textColor: textColor,
                      ),
                    if (!_showResults) const SizedBox(height: 10),
                    // Additional metrics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Distance metric
                        MetricCard(
                          icon: Icons.straighten,
                          value: _distance.toStringAsFixed(2),
                          unit: 'km',
                          label: 'Distance',
                          accentColor: accentColor,
                          textColor: textColor,
                        ),
                        // Time metric
                        MetricCard(
                          icon: Icons.timer,
                          value: _formatDuration(_elapsedTime),
                          unit: '',
                          label: 'Time',
                          accentColor: accentColor,
                          textColor: textColor,
                        ),
                        // Calories metric
                        MetricCard(
                          icon: Icons.local_fire_department,
                          value: _calories.toStringAsFixed(1),
                          unit: 'cal',
                          label: 'Calories',
                          accentColor: accentColor,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            ActionButtons(
              primaryColor: accentColor,
              isSessionActive: _isSessionActive,
              onStart: _startSession,
              onStop: _stopSession,
              onReset: _resetPedometer,
              onBack: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// Session results card shown after stopping a session
class SessionResultCard extends StatelessWidget {
  final double averageSpeed;
  final Color accentColor;
  final Color textColor;

  const SessionResultCard({
    Key? key,
    required this.averageSpeed,
    required this.accentColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Session Results',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.speed,
                color: accentColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Average Speed: ',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              Text(
                '${averageSpeed.toStringAsFixed(2)} km/h',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// MODULAR COMPONENTS

class StatusHeader extends StatelessWidget {
  final String status;
  final bool isActive;
  final Color primaryColor;

  const StatusHeader({
    Key? key,
    required this.status,
    required this.isActive,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.13),
        border: Border(
          bottom: BorderSide(color: Colors.blueAccent.withOpacity(0.18)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            status == 'walking'
                ? Icons.directions_walk
                : status == 'Ready'
                    ? Icons.sports_score
                    : Icons.accessibility_new,
            color: Colors.blueAccent,
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'Session Active - Status: $status' : 'Status: $status',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(left: 8),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class StepCounter extends StatelessWidget {
  final int steps;
  final Color primaryColor;
  final Color lightColor;
  final bool isActive;

  const StepCounter({
    Key? key,
    required this.steps,
    required this.primaryColor,
    required this.lightColor,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF23242B), // dark
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF181A20), // even darker
          border: Border.all(
            color: isActive ? Colors.blueAccent : Colors.blueGrey,
            width: isActive ? 3 : 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              steps.toString(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'STEPS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blueAccent.withOpacity(0.7),
                letterSpacing: 2,
              ),
            ),
            if (!isActive && steps == 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Press START',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color accentColor;
  final Color textColor;

  const MetricCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.accentColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF23242B), // dark
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: accentColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextSpan(
                  text: unit.isNotEmpty ? ' $unit' : '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final Color primaryColor;
  final bool isSessionActive;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;
  final VoidCallback onBack;

  const ActionButtons({
    Key? key,
    required this.primaryColor,
    required this.isSessionActive,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Start/Stop Button
          ElevatedButton.icon(
            onPressed: isSessionActive ? onStop : onStart,
            icon: Icon(isSessionActive ? Icons.stop : Icons.play_arrow),
            label: Text(isSessionActive ? 'STOP' : 'START'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSessionActive ? Colors.red : Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Reset Button
          ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF23242B),
              foregroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
          // Home Button
          ElevatedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.home),
            label: const Text('Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF23242B),
              foregroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
