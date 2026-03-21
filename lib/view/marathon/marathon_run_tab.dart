import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/marathon_provider.dart';
import '../../constant/appTheme.dart';

// ── Colour tokens ─────────────────────────────────────────────────────────────
const _digitOuter  = Color(0xFF6DAAFB);
const _digitInner  = AppTheme.primaryBlue;
const _metricOuter = Color(0xFFEEF1FA);
const _metricCard  = Color(0xFFDEE9FE);
const _chipBg      = Color(0xFF002661);
const _chipText    = Color(0xFFDFE8F4);
const _labelColor  = AppTheme.primaryBlue;
const _btnColor    = AppTheme.primaryBlue;

// Height of the SVG header section
const double _headerH = 200.0;

// ─────────────────────────────────────────────────────────────────────────────
class MarathonRunTab extends ConsumerWidget {
  const MarathonRunTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runState  = ref.watch(liveRunProvider);
    final isRunning = runState.isRunning;

    final int m = runState.elapsedSeconds ~/ 60;
    final int s = runState.elapsedSeconds % 60;
    final String timeFormatted =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    final String distStr =
    runState.distanceKm.toStringAsFixed(2).replaceAll('.', '');
    final List<String> digits = distStr.padLeft(4, '0').split('');

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Header — scrolls with the page ──────────────────────────
            SizedBox(
              height: _headerH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset(
                    'assets/ghm/frame03.svg',
                    fit: BoxFit.cover,
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 10),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Color(0xFF1C2340),
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Rest of content ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── "DISTANCE : KM" ───────────────────────────────────
                  const Text(
                    'DISTANCE : KM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontUnivers,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Digit block ────────────────────────────────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // 8px padding each side + 6px gap within each pair + 28px colon zone
                      final double available = constraints.maxWidth - 16 - 12 - 28;
                      final double digitW = (available / 4).floorToDouble();
                      final double digitH = (digitW * 1.28).floorToDouble();

                      return Container(
                        width: double.infinity,
                        height: digitH + 16,
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: _digitOuter,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _DigitPair(
                              left: digits[0], right: digits[1],
                              digitW: digitW,  digitH: digitH,
                            ),
                            _ColonSeparator(height: digitH),
                            _DigitPair(
                              left: digits[2], right: digits[3],
                              digitW: digitW,  digitH: digitH,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Metric grid ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _metricOuter,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  svgPath: 'assets/ghm/icon1.svg',
                                  label: 'Current Pace',
                                  value: '${runState.currentPace.toStringAsFixed(2)} /KM',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _MetricCard(
                                  svgPath: 'assets/ghm/icon2.svg',
                                  label: 'Total Steps',
                                  value: '${runState.stepCount}',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  svgPath: 'assets/ghm/icon3.svg',
                                  label: 'Calories',
                                  value: '${(runState.stepCount * 0.04).toInt()}',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _MetricCard(
                                  svgPath: 'assets/ghm/icon4.svg',
                                  label: 'Time',
                                  value: timeFormatted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Action buttons ─────────────────────────────────────
                  if (isRunning) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            onPressed: () => runState.isPaused
                                ? ref.read(liveRunProvider.notifier).resumeRun()
                                : ref.read(liveRunProvider.notifier).pauseRun(),
                            label: runState.isPaused ? 'RESUME' : 'STOP RUN',
                            color: _btnColor,
                            fontFamily: AppTheme.fontUnivers,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            onPressed: () =>
                                ref.read(liveRunProvider.notifier).stopRun(),
                            label: 'STOP',
                            color: Colors.redAccent,
                            fontFamily: AppTheme.fontUnivers,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _ActionButton(
                      onPressed: () =>
                          ref.read(liveRunProvider.notifier).startRun(),
                      label: 'START RUN',
                      color: _btnColor,
                      fontFamily: AppTheme.fontUnivers,
                    ),
                  ],

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIGIT PAIR
// ─────────────────────────────────────────────────────────────────────────────
class _DigitPair extends StatelessWidget {
  final String left, right;
  final double digitW, digitH;
  const _DigitPair({
    required this.left, required this.right,
    required this.digitW, required this.digitH,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tile(left),
        const SizedBox(width: 6),
        _tile(right),
      ],
    );
  }

  Widget _tile(String digit) {
    final double fontSize = (digitW * 0.70).clamp(24.0, 72.0);
    return Container(
      width: digitW,
      height: digitH,
      decoration: ShapeDecoration(
        color: _digitInner,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontFamily: AppTheme.fontGeneralSans,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COLON SEPARATOR
// ─────────────────────────────────────────────────────────────────────────────
class _ColonSeparator extends StatelessWidget {
  final double height;
  const _ColonSeparator({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_dot(), const SizedBox(height: 10), _dot()],
      ),
    );
  }

  Widget _dot() => Container(
    width: 12,
    height: 12,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: _digitInner,
        shape: BoxShape.circle,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// METRIC CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String svgPath, label, value;
  const _MetricCard({
    required this.svgPath,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _metricCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(svgPath, width: 22, height: 22),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: _labelColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.fontUnivers,
                  height: 1.25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _chipBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _chipText,
                fontSize: 17,
                fontFamily: AppTheme.fontGeneralSans,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;
  final String fontFamily;
  const _ActionButton({
    required this.onPressed,
    required this.label,
    required this.color,
    this.fontFamily = AppTheme.fontGeneralSans,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: fontFamily,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
