import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/marathon_provider.dart';
import '../../model/marathon_models.dart';
import 'package:intl/intl.dart';
import '../../constant/appTheme.dart';
import 'dart:ui';

// ── Design Tokens ──────────────────────────────────────────────────────────
const _cardGray   = Color(0xFFE8ECEF);
const _barFaded  = Color(0xFFB8BFF0); // faded bar for non-today days
const _iconCircle = Color(0xFF2C3349); // dark circle behind run icon

const _cardShadow = [
  BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3)),
];

// ─────────────────────────────────────────────────────────────────────────────
class MarathonDashboardTab extends ConsumerWidget {
  const MarathonDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync   = ref.watch(progressStatsProvider);
    final recentRunsAsync = ref.watch(recentRunsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: progressAsync.when(
        data: (stats) => RefreshIndicator(
          color: AppTheme.primaryBlue,
          onRefresh: () async {
            ref.invalidate(progressStatsProvider);
            ref.invalidate(recentRunsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. SVG Header (track illustration) ─────────────────────
                const _DashboardHeader(),

                // ── 2. "DASHBOARD" title BELOW the image ───────────────────
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: const Text(
                    'DASHBOARD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textMain,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontUnivers,
                      height: 1.2,
                    ),
                  ),
                ),

                // ── thin divider ────────────────────────────────────────────
                Container(height: 1, color: const Color(0xFFD4D8EA)),
                const SizedBox(height: 18),

                // ── 3. Content with horizontal padding ──────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 2×2 Stat Cards ────────────────────────────────────
                      _StatsGrid(stats: stats),
                      const SizedBox(height: 16),

                      // ── Daily Distance Chart ──────────────────────────────
                      _ChartCard(stats: stats),
                      const SizedBox(height: 20),

                      // ── Last 5 Runs header ────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Last 5 Runs',
                            style: TextStyle(
                              color: AppTheme.textMain,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppTheme.fontUnivers,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                color: AppTheme.accentBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppTheme.fontGeneralSans,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Runs list ─────────────────────────────────────────
                      recentRunsAsync.when(
                        data: (runs) {
                          if (runs.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding:
                              const EdgeInsets.symmetric(vertical: 40),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundGray,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'No runs logged yet.',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary, fontSize: 14, fontFamily: AppTheme.fontGeneralSans),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: runs.map((run) {
                              final dateStr = DateFormat('MMM d')
                                  .format(run.createdAt.toLocal());
                              final timeStr = DateFormat('hh:mm a')
                                  .format(run.createdAt.toLocal());
                              final int mm =
                              run.durationMinutes.floor();
                              final int ss =
                              ((run.durationMinutes - mm) * 60)
                                  .round();
                              final String durStr =
                                  '${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
                              return Padding(
                                padding:
                                const EdgeInsets.only(bottom: 12),
                                child: _RunCard(
                                  distanceKm: run.distanceKm,
                                  dateStr: dateStr,
                                  timeStr: timeStr,
                                  durStr: durStr,
                                  paceStr:
                                  '${run.avgPace.toStringAsFixed(2)}/KM',
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue)),
                        ),
                        error: (e, _) => Text('Error: $e',
                            style: const TextStyle(
                                color: Colors.redAccent)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFDEE9FE), width: 1),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF002661),
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final ProgressStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: _StatCard(
                      label: 'Streak',
                      value: '${stats.streak} Days')),
              const SizedBox(width: 16),
              Expanded(
                  child: _StatCard(
                      label: 'This Week',
                      value:
                      '${stats.weeklyKm.toStringAsFixed(2)} KM')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: _StatCard(
                      label: 'Avg Pace',
                      value: stats.weeklyPace.toStringAsFixed(2))),
              const SizedBox(width: 16),
              Expanded(
                  child: _StatCard(
                      label: 'Improvement',
                      value: '+${stats.improvement}%')),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      decoration: BoxDecoration(
        color: _cardGray,                         
        borderRadius: BorderRadius.circular(8),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.fontUnivers,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontGeneralSans,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final ProgressStats stats;
  const _ChartCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final daily = stats.dailyStats;
    double maxVal =
    daily.map((e) => e.distance).fold(0.0, (a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 1.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),                      
        borderRadius: BorderRadius.circular(18),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Distance',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.fontUnivers,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${stats.weeklyKm.toStringAsFixed(2)} KM',
            style: const TextStyle(
              color: AppTheme.primaryBlue,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              fontFamily: AppTheme.fontUnivers,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: daily.map((stat) {
                final double barH =
                ((stat.distance / maxVal) * 90).clamp(4.0, 90.0);
                final bool isToday = stat.isToday;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        width: 28,
                        height: barH,
                        decoration: BoxDecoration(
                          color: isToday ? AppTheme.primaryBlue : _barFaded,
                          borderRadius: const BorderRadius.only(
                            topLeft:  Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        stat.dayName[0],
                        style: TextStyle(
                          color: isToday ? AppTheme.primaryBlue : AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: isToday
                              ? FontWeight.w800
                              : FontWeight.w500,
                          fontFamily: AppTheme.fontGeneralSans,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _RunCard extends StatelessWidget {
  final double distanceKm;
  final String dateStr, timeStr, durStr, paceStr;
  const _RunCard({
    required this.distanceKm,
    required this.dateStr,
    required this.timeStr,
    required this.durStr,
    required this.paceStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _iconCircle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_run,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Practice Run',
                  style: TextStyle(
                    color: AppTheme.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTheme.fontUnivers,
                  ),
                ),
              ),
              Text(
                '${distanceKm.toStringAsFixed(2)} KM',
                style: TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: AppTheme.fontGeneralSans,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              _InfoChip(icon: Icons.calendar_today_outlined, text: dateStr),
              const SizedBox(width: 20),
              _InfoChip(icon: Icons.access_time_outlined, text: timeStr),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              _InfoChip(icon: Icons.timer_outlined, text: durStr),
              const SizedBox(width: 20),
              _InfoChip(icon: Icons.speed_outlined, text: paceStr),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String   text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.accentBlue, size: 14),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: AppTheme.fontGeneralSans,
          ),
        ),
      ],
    );
  }
}
