import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/marathon_provider.dart';
import '../../constant/appTheme.dart';
import '../../utils/animate_gradient_background.dart';

class MarathonRunTab extends ConsumerWidget {
  const MarathonRunTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runState = ref.watch(liveRunProvider);
    final isRunning = runState.isRunning;

    // Format timer
    int m = runState.elapsedSeconds ~/ 60;
    int s = runState.elapsedSeconds % 60;
    String timeFormatted =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Stack(
      children: [
        const AnimatedGradientBackground(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text('DISTANCE',
                  style: TextStyle(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                            blurRadius: 10,
                            color: AppTheme.primaryColor,
                            offset: Offset(0, 0)),
                      ])),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    runState.distanceKm.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                            color: AppTheme.primaryColor,
                            blurRadius: 25,
                            offset: Offset(0, 0))
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('KM',
                      style: TextStyle(
                          color: Colors.white70,
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(flex: 1),

              // 4 Grid metrics
              Row(
                children: [
                  Expanded(
                      child: _buildMetricBox(
                          Icons.timer_outlined, 'TIME', timeFormatted)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildMetricBox(Icons.speed, 'CURRENT PACE',
                          '${runState.currentPace.toStringAsFixed(2)} /km')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildMetricBox(Icons.directions_walk,
                          'TOTAL STEPS', '${runState.stepCount}')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildMetricBox(
                          Icons.local_fire_department_outlined,
                          'CALORIES',
                          '${(runState.stepCount * 0.04).toInt()}')),
                ],
              ),

              const Spacer(flex: 2),

              // Action Buttons
              if (isRunning) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (runState.isPaused) {
                            ref.read(liveRunProvider.notifier).resumeRun();
                          } else {
                            ref.read(liveRunProvider.notifier).pauseRun();
                          }
                        },
                        icon: Icon(
                          runState.isPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.black,
                        ),
                        label: Text(
                          runState.isPaused ? 'RESUME' : 'PAUSE',
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final notifier = ref.read(liveRunProvider.notifier);
                          final service = ref.read(marathonServiceProvider);
                          final user = ref.read(marathonUsernameProvider);

                          final double finalDist = runState.distanceKm;
                          final int finalSeconds = runState.elapsedSeconds;

                          notifier.stopRun();

                          try {
                            if (finalDist >= 0.001) {
                              final double totalMinutes = finalSeconds / 60.0;
                              final double finalAvgPace = finalDist > 0
                                  ? (totalMinutes / finalDist)
                                  : 0.0;

                              await service.logRun(
                                username: user,
                                distanceKm: finalDist,
                                durationMinutes: totalMinutes,
                                avgPace: finalAvgPace,
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Run saved to Leaderboard!')));
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Run too short to save (<1m)')));
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Failed to save log: $e')));
                            }
                          } finally {
                            notifier.resetRun();
                            ref.invalidate(progressStatsProvider);
                            ref.invalidate(distanceLeaderboardProvider);
                            ref.invalidate(allRunsProvider);
                            ref.invalidate(recentRunsProvider);
                          }
                        },
                        icon: const Icon(Icons.stop_circle_outlined,
                            color: Colors.redAccent),
                        label: const Text('STOP',
                            style: TextStyle(
                                color: Colors.redAccent,
                                letterSpacing: 1,
                                fontFamily: AppTheme.fontFamily,
                                fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.redAccent, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showPermissionDialog(context, ref);
                    },
                    style:
                        AppTheme.darkTheme.elevatedButtonTheme.style?.copyWith(
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 20)),
                    ),
                    child: const Text('START RUN'),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  void _showPermissionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Background Tracking',
            style: TextStyle(
                color: Colors.white,
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To accurately track your run even when the screen is off or the app is in the background, we need two things:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 16),
            Text('1. Notification Permission',
                style: TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            Text('To show persistent live stats in your tray.',
                style: TextStyle(color: Colors.white60, fontSize: 12)),
            SizedBox(height: 12),
            Text('2. Battery Optimization Exemption',
                style: TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            Text('To prevent the system from stopping the tracker mid-run.',
                style: TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(liveRunProvider.notifier).startRun();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('CONTINUE',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(IconData icon, String title, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 10,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
