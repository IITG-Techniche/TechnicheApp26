import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import '../../../constant/appTheme.dart';
import '../../../services/map_cache_service.dart';


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
                          border: Border.all(color: Colors.grey.shade200, width: 1),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: widget.routePoints.isNotEmpty
                            ? FlutterMap(
                                options: MapOptions(
                                  initialCameraFit: CameraFit.bounds(
                                    bounds: LatLngBounds.fromPoints(widget.routePoints),
                                    padding: const EdgeInsets.all(40.0),
                                  ),
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none, // Disable all interactions (static feel)
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                                    userAgentPackageName: 'com.techniche.techniche26',
                                    tileProvider: CachedTileProvider(
                                      store: MapCacheService.cacheStore,
                                    ),
                                  ),
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: widget.routePoints,
                                        color: AppTheme.primaryBlue,
                                        strokeWidth: 5.0,
                                      ),
                                    ],
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      // Start Marker
                                      Marker(
                                        point: widget.routePoints.first,
                                        width: 12,
                                        height: 12,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                      // End Marker
                                      Marker(
                                        point: widget.routePoints.last,
                                        width: 16,
                                        height: 16,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const Center(child: Text('No route points recorded')),
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
