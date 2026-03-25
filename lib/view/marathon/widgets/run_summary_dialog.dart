import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../constant/appTheme.dart';


class RunSummaryDialog extends StatefulWidget {
  final List<LatLng> routePoints;
  final double distanceKm;
  final int totalSeconds;
  final double avgSpeed; // km/h
  final int calories;

  const RunSummaryDialog({
    super.key,
    required this.routePoints,
    required this.distanceKm,
    required this.totalSeconds,
    required this.avgSpeed,
    required this.calories,
  });

  @override
  State<RunSummaryDialog> createState() => _RunSummaryDialogState();
}

class _RunSummaryDialogState extends State<RunSummaryDialog> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSharing = false;

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }

  Future<void> _shareScreenshot() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // 1. Capture the widget
      RenderRepaintBoundary? boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2. Save to temp file
      final directory = await getTemporaryDirectory();
      final imagePath = File('${directory.path}/run_summary_${DateTime.now().millisecondsSinceEpoch}.png');
      await imagePath.writeAsBytes(pngBytes);

      // 3. Share using share_plus
      final xFile = XFile(imagePath.path);
      final String shareMessage = "🏃 I just crushed my GHM Practice Run! \n"
          "📊 Distance: ${widget.distanceKm} km \n"
          "🏆 Check out my rank on the GHM Leaderboard in the Techniche App! \n\n"
          "🔥 Join me and start your fitness journey! Download the official Techniche App here: \n"
          "🔗 https://play.google.com/store/apps/details?id=com.techniche.techniche_app"; 
      
      await Share.shareXFiles([xFile], text: shareMessage);
    } catch (e) {
      debugPrint('Error sharing screenshot: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Run Summary',
              style: TextStyle(
                color: Colors.black,
                fontFamily: AppTheme.fontGeneralSans,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),

          Expanded(
            child: Container (
              child: RepaintBoundary(
                key: _boundaryKey,
                child: Container(
                  color: Colors.white, 
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image.asset(
                            //   'assets/ghm.png',
                            //   fit: BoxFit.fill,
                            // ),
                            Container(color: Colors.black.withOpacity(0.5)),
                            if (widget.routePoints.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(40.0), // Padding so route doesn't touch image edges
                                child: CustomPaint(
                                  painter: RoutePainter(
                                    points: widget.routePoints,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              )
                            else
                              const Center(child: Text('No route points recorded')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Main Stats ───────────────────────────────────────────
                      Text(
                        'Great Job!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontGeneralSans,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMM d • h:mm a').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatTile(context, 'Distance', '${widget.distanceKm.toStringAsFixed(2)} km', Icons.directions_run),
                          _buildStatTile(context, 'Duration', _formatDuration(widget.totalSeconds), Icons.timer_outlined),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatTile(context, 'Avg Speed', '${widget.avgSpeed.toStringAsFixed(1)} km/h', Icons.speed),
                          _buildStatTile(context, 'Calories', '${widget.calories} kcal', Icons.local_fire_department_outlined),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      // Brand watermark inside screenshot
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'IITG TECHNICHE 2026',
                              style: TextStyle(
                                letterSpacing: 2,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBlue.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // ── Bottom Action Buttons ─────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _shareScreenshot,
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text('Share Progress', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Done', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String label, String value, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: (screenWidth - 60) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the route polylines relative to the bounding box of coordinates
class RoutePainter extends CustomPainter {
  final List<LatLng> points;
  final Color color;

  RoutePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // 1. Find bounding box
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    double latRange = (maxLat - minLat).abs();
    double lngRange = (maxLng - minLng).abs();

    // Fix: Enforce a minimum range (approx 1km) so short runs (e.g. 0.01km) 
    // don't appear misleadingly large by filling the entire canvas.
    const double minRange = 0.008; // Roughly 900m at equator
    if (latRange < minRange) {
      double diff = (minRange - latRange) / 2;
      minLat -= diff;
      maxLat += diff;
      latRange = minRange;
    }
    if (lngRange < minRange) {
      double diff = (minRange - lngRange) / 2;
      minLng -= diff;
      maxLng += diff;
      lngRange = minRange;
    }

    // 2. Map coordinates to canvas space
    // Scale points to fit, maintaining aspect ratio
    final double scaleX = size.width / lngRange;
    final double scaleY = size.height / latRange;
    final double scale = (scaleX < scaleY) ? scaleX : scaleY;

    // Center the route in the canvas
    final double offsetX = (size.width - (lngRange * scale)) / 2;
    final double offsetY = (size.height - (latRange * scale)) / 2;

    List<Offset> offsets = [];
    for (var p in points) {
      double x = (p.longitude - minLng) * scale + offsetX;
      double y = size.height - ((p.latitude - minLat) * scale + offsetY); // Flip Y for canvas
      offsets.add(Offset(x, y));
    }

    // 3. Draw Polyline
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = ui.Path();
    path.moveTo(offsets[0].dx, offsets[0].dy);
    for (int i = 1; i < offsets.length; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }
    
    // Shadow for depth
    canvas.drawPath(path, Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    canvas.drawPath(path, paint);

    // 4. Start & End Markers
    final startPaint = Paint()..color = Colors.green;
    final endPaint = Paint()..color = Colors.red;
    
    // White ring for markers
    final ringPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5;

    canvas.drawCircle(offsets.first, 6, startPaint);
    canvas.drawCircle(offsets.first, 6, ringPaint);
    
    canvas.drawCircle(offsets.last, 8, endPaint);
    canvas.drawCircle(offsets.last, 8, ringPaint);
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) => oldDelegate.points != points;
}
