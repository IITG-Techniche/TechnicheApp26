import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/marathon_provider.dart';
import '../../constant/appTheme.dart';
import 'widgets/live_run_map.dart';
import 'widgets/run_summary_dialog.dart';

const _statCardBg   = Color(0xFF002661);
const _statCardText = Color(0xFFDFE8F4);
const _btnColor     = AppTheme.primaryBlue;

class MarathonRunTab extends ConsumerStatefulWidget {
  const MarathonRunTab({super.key});

  @override
  ConsumerState<MarathonRunTab> createState() => _MarathonRunTabState();
}

class _MarathonRunTabState extends ConsumerState<MarathonRunTab> {
  @override
  void initState() {
    super.initState();
    // Request permissions and start tracking immediately when the Run Tab is opened
    Future.microtask(() {
      ref.read(liveRunProvider.notifier).enableTrackingIfPermitted();
    });
  }

  /// Trigger haptic feedback reliably using the platform channel
  Future<void> _hapticLong() async {
    await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate', 'HapticFeedbackType.heavyImpact');
  }

  Future<void> _hapticShort() async {
    await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate', 'HapticFeedbackType.lightImpact');
  }

  @override
  Widget build(BuildContext context) {
    final runState = ref.watch(liveRunProvider);
    final isRunning = runState.isRunning;

    // Listen for errors and show SnackBar
    ref.listen<String?>(
      liveRunProvider.select((s) => s.errorMessage),
      (previous, next) {
        if (next != null && next.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next), backgroundColor: Colors.redAccent),
          );
        }
      },
    );

    return Column(
      children: [
        // ── Live Map ────────────────────────────────────────────────────
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: LiveRunMap(
              routePoints: runState.routePoints,
              currentLocation: runState.currentLocation,
              hasGpsFix: runState.hasGpsFix,
              isRunning: isRunning,
              currentHeading: runState.currentHeading,
            ),
          ),
        ),

        // ── Stats + Controls panel ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Stats row ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatPill(
                    icon: Icons.speed,
                    label: 'SPEED',
                    value: '${runState.avgSpeed.toStringAsFixed(1)} km/h',
                  ),
                  const SizedBox(width: 8),
                  _StatPill(
                    icon: Icons.timer_outlined,
                    label: 'TIME',
                    value: _formatDuration(runState.elapsedSeconds),
                  ),
                  const SizedBox(width: 8),
                  _StatPill(
                    icon: Icons.local_fire_department_outlined,
                    label: 'CALORIES',
                    value: runState.calories.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Main Distance ──────────────────────────────────────────
              Text(
                '${runState.distanceKm.toStringAsFixed(2)} km',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  fontFamily: AppTheme.fontGeneralSans,
                  color: Color(0xFF002661),
                ),
              ),
              const SizedBox(height: 16),

              // ── Controls ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: isRunning
                  ? Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            onPressed: () {
                              _hapticShort();
                              if (runState.isPaused) {
                                ref.read(liveRunProvider.notifier).resumeRun();
                              } else {
                                ref.read(liveRunProvider.notifier).pauseRun();
                              }
                            },
                            label: runState.isPaused ? 'RESUME' : 'PAUSE',
                            color: _btnColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            onPressed: () async {
                              if (runState.isSaving) return;
                              _hapticLong();
                              final finalState = runState;
                              await ref.read(liveRunProvider.notifier).stopRun();
                              if (context.mounted) {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        RunSummaryDialog(
                                      routePoints: finalState.routePoints,
                                      distanceKm: finalState.distanceKm,
                                      totalSeconds: finalState.elapsedSeconds,
                                      avgSpeed: finalState.avgSpeed,
                                      calories: finalState.calories,
                                    ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
                                          .chain(CurveTween(curve: Curves.easeOutCubic));
                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 400),
                                  ),
                                );
                              }
                            },
                            label: 'FINISH',
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    )
                  : _ActionButton(
                      onPressed: () {
                        _hapticLong();
                        ref.read(liveRunProvider.notifier).startRun();
                      },
                      label: 'START RUN',
                      color: _btnColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatPill({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(color: _statCardBg, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, color: _statCardText, size: 16),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, height: 1.0)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: _statCardText.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;
  const _ActionButton({required this.onPressed, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
