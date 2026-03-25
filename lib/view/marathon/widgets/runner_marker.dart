import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// A high-performance, smooth-rotating marker for the runner.
/// It listens directly to the compass stream for zero-latency orientation feedback.
class RunnerMarker extends StatefulWidget {
  final double? heading; // Initial heading from GPS or State
  const RunnerMarker({super.key, this.heading});

  @override
  State<RunnerMarker> createState() => _RunnerMarkerState();
}

class _RunnerMarkerState extends State<RunnerMarker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _currentHeading = 0;

  @override
  void initState() {
    super.initState();
    _currentHeading = widget.heading ?? 0;
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _scaleAnim = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // Initialize compass listener with fallback
    _initCompass();
  }

  void _initCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((event) {
      // Use heading or headingForCameraMode
      double? h = event.heading ?? event.headingForCameraMode;
      if (h != null && mounted) {
        setState(() {
          // Normalize to 0-360 for consistent turns
          _currentHeading = h % 360.0;
        });
      }
    }, onError: (e) {
      debugPrint('Compass Error in Marker: $e');
    });
  }

  @override
  void didUpdateWidget(covariant RunnerMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with GPS heading only for major drifts (teleportation/fix shift)
    if (widget.heading != null) {
      final delta = (widget.heading! - _currentHeading).abs();
      if (delta > 90 && delta < 270) {
        setState(() {
          _currentHeading = widget.heading! % 360.0;
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // turns for AnimatedRotation
    final turns = _currentHeading / 360.0;

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Pulsing ring
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF002661).withOpacity(_opacityAnim.value),
                ),
              ),
            ),
          ),
          
          // 2. Ultra High-speed rotation wrapper
          AnimatedRotation(
            turns: turns,
            duration: const Duration(milliseconds: 20), // Instantaneous feel
            curve: Curves.linear,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Directional Indicator Tip (North)
                Positioned(
                  top: -6,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFF002661),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                
                // Solid center dot with North Icon
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF002661),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x60000000),
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.north, 
                      color: Colors.white,
                      size: 16,
                      weight: 900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
