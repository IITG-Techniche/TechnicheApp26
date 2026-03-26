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

class _RunnerMarkerState extends State<RunnerMarker> {
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _currentHeading = 0;

  @override
  void initState() {
    super.initState();
    _currentHeading = widget.heading ?? 0;
    
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
          // 2. The "Torch/Beam" (expanding cone)
          AnimatedRotation(
            turns: turns,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            child: SizedBox(
              width: 900, // Increased reach
              height: 900,
              child: CustomPaint(
                painter: _BeamPainter(
                  color: const Color(0xFF002661),
                  beamWidth: 90, // Keeping user's manual 90
                ),
              ),
            ),
          ),

          // 3. Central Dot (Location) - No pulsing circle here as requested
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF002661),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeamPainter extends CustomPainter {
  final Color color;
  final double beamWidth;
  _BeamPainter({required this.color, this.beamWidth = 70});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.4),
          color.withOpacity(0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.85, 1.0], // More reach
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    
    // Create cone pointing upwards (North by default)
    final double startAngle = -90 - (beamWidth / 2);
    
    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: size.width / 2),
      startAngle * (3.14159 / 180),
      beamWidth * (3.14159 / 180),
      false,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
