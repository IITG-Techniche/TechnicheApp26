import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/marathon_provider.dart';

class MarathonRunTab extends ConsumerWidget {
  const MarathonRunTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runState = ref.watch(liveRunProvider);
    final isRunning = runState.isRunning;

    int m = runState.elapsedSeconds ~/ 60;
    int s = runState.elapsedSeconds % 60;
    String timeFormatted =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    String distStr =
    runState.distanceKm.toStringAsFixed(2).replaceAll('.', '');
    List<String> digits = distStr.padLeft(4, '0').split('');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          SizedBox(
            height: 144,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SvgPicture.asset('assets/ghm/frame03.svg', fit: BoxFit.cover),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, top: 10),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 47, height: 47,
                          padding: const EdgeInsets.all(12),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 1, color: Color(0xFFB2B8BF)),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: SvgPicture.asset('assets/ghm/iconback.svg'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height:48),

          // ── Content ─────────────────────────────────────────────────────
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Distance label
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'DISTANCE : KM',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Univers',
                          fontWeight: FontWeight.w700,
                          height: 1.30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Digit Block ─────────────────────────────────────
                    Container(
                      width: double.infinity,
                      height: 107,
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF6DAAFB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildDigitPair(digits[0], digits[1]),
                          _buildColon(),
                          _buildDigitPair(digits[2], digits[3]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Metric Grid ─────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF3F3F3),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1, color: Color(0xFFE8E8E8)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 16,
                        children: [
                          Row(
                            spacing: 16,
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  'assets/ghm/icon1.svg',
                                  'Current Pace',
                                  '${runState.currentPace.toStringAsFixed(0)} /KM',
                                ),
                              ),
                              Expanded(
                                child: _buildMetricCard(
                                  'assets/ghm/icon2.svg',
                                  'Total Steps',
                                  '${runState.stepCount}',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 16,
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  'assets/ghm/icon3.svg',
                                  'Calories',
                                  '${(runState.stepCount * 0.04).toInt()}',
                                ),
                              ),
                              Expanded(
                                child: _buildMetricCard(
                                  'assets/ghm/icon4.svg',
                                  'Time',
                                  timeFormatted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ── Action Buttons ───────────────────────────────────
                    if (isRunning) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              onPressed: () => runState.isPaused
                                  ? ref
                                  .read(liveRunProvider.notifier)
                                  .resumeRun()
                                  : ref
                                  .read(liveRunProvider.notifier)
                                  .pauseRun(),
                              label: runState.isPaused ? 'RESUME' : 'PAUSE',
                              color: const Color(0xFF1E56C5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              onPressed: () =>
                                  ref.read(liveRunProvider.notifier).stopRun(),
                              label: 'STOP',
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildActionButton(
                        onPressed: () =>
                            ref.read(liveRunProvider.notifier).startRun(),
                        label: 'START RUN',
                        color: const Color(0xFF1E56C5),
                      ),
                    ],
                    const SizedBox(height: 27),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a left+right digit pair (e.g. "2" and "1")
  Widget _buildDigitPair(String left, String right) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 75,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: ShapeDecoration(
            color: const Color(0xFF266EF1),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          child: Text(
            left,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontFamily: 'TT Interphases Pro Mono Trl',
              fontWeight: FontWeight.w700,
              height: 1.30,
            ),
          ),
        ),
        Container(
          width: 75,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: ShapeDecoration(
            color: const Color(0xFF266EF1),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
          child: Text(
            right,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontFamily: 'TT Interphases Pro Mono Trl',
              fontWeight: FontWeight.w700,
              height: 1.30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColon() {
    return SizedBox(
      width: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Container(
            width: 16, height: 16,
            decoration: ShapeDecoration(
              color: const Color(0xFF266EF1),
              shape: OvalBorder(
                side: BorderSide(width: 3, color: const Color(0xFFFEFEFE)),
              ),
            ),
          ),
          Container(
            width: 16, height: 16,
            decoration: ShapeDecoration(
              color: const Color(0xFF266EF1),
              shape: OvalBorder(
                side: BorderSide(width: 3, color: const Color(0xFFFEFEFE)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String svgPath, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: const Color(0xFFDEE9FE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // Icon row (wire up your SVG assets here)
          SvgPicture.asset(svgPath, width: 20, height: 20),

          // Label — General Sans 20 / w500
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF002661),
              fontSize: 20,
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w500,
              height: 1.30,
            ),
          ),

          // Value chip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: ShapeDecoration(
              color: const Color(0xFF002661),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFDFE8F4),
                fontSize: 20,
                fontFamily: 'TT Interphases Pro Mono Trl',
                fontWeight: FontWeight.w400,
                height: 1.30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}