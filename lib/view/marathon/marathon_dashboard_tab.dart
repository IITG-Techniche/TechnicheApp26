import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/marathon_provider.dart';
import '../../model/marathon_models.dart';
import 'package:intl/intl.dart';
import 'marathon_all_runs_screen.dart';

class MarathonDashboardTab extends ConsumerWidget {
  const MarathonDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressStatsProvider);
    final recentRunsAsync = ref.watch(recentRunsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFB2B8BF), width: 1),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/ghm/iconback.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'DASHBOARD',
          style: TextStyle(
            color: Color(0xFF0A1929),
            fontFamily: 'Univers',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: const Color(0xFFE8EBF0), height: 0.5),
        ),
      ),
      body: progressAsync.when(
        data: (stats) => RefreshIndicator(
          color: const Color(0xFF175BCC),
          backgroundColor: Colors.white,
          onRefresh: () async {
            ref.invalidate(progressStatsProvider);
            ref.invalidate(recentRunsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatGrid(stats: stats),
                const SizedBox(height: 16),
                _ChartCard(stats: stats),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Last 5 Runs',
                        style: TextStyle(
                          color: Color(0xFF0A1929),
                          fontFamily: 'Univers',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MarathonAllRunsScreen(),
                          ),
                        ),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: Color(0xFF175BCC),
                            fontFamily: 'General Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                recentRunsAsync.when(
                  data: (runs) {
                    if (runs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No runs logged yet.',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontFamily: 'General Sans',
                            ),
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
                        final int m = run.durationMinutes.floor();
                        final int s =
                        ((run.durationMinutes - m) * 60).round();
                        final String durStr =
                            '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RunCard(
                            distanceKm: run.distanceKm,
                            dateStr: dateStr,
                            timeStr: timeStr,
                            durStr: durStr,
                            paceStr: '${run.avgPace.toStringAsFixed(2)}/KM',
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF175BCC)),
                  ),
                  error: (e, _) => Text('Error: $e',
                      style: const TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF175BCC)),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.red)),
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ─────────────────────────────────────────────
// STAT GRID
// ─────────────────────────────────────────────
class _StatGrid extends StatelessWidget {
  final ProgressStats stats;
  const _StatGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0DAF6), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Streak',
                  value: '${stats.streak} Days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'This Week',
                  value: '${stats.weeklyKm.toStringAsFixed(2)} KM',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Avg Pace',
                  value: stats.weeklyPace.toStringAsFixed(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Improvement',
                  value: '+${stats.improvement}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFDEE9FE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0A1929),
              fontFamily: 'General Sans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF002661),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFDFE8F4),
                fontFamily: 'TT Interphases Pro Mono Trl',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CHART CARD
// ─────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final ProgressStats stats;
  const _ChartCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final dailyStats = stats.dailyStats;
    double maxVal = dailyStats
        .map((e) => e.distance)
        .fold(0.0, (a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Distance',
            style: TextStyle(
              color: Color(0xFF175BCC),
              fontFamily: 'General Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${stats.weeklyKm.toStringAsFixed(2)} KM',
            style: const TextStyle(
              color: Color(0xFF175BCC),
              fontFamily: 'TT Interphases Pro Mono Trl',
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailyStats.map((stat) {
                final double barH =
                ((stat.distance / maxVal) * 108).clamp(4.0, 108.0);
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: barH,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF175BCC),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stat.dayName[0],
                        style: TextStyle(
                          color: stat.isToday
                              ? const Color(0xFF175BCC)
                              : const Color(0xFF888888),
                          fontFamily: 'General Sans',
                          fontSize: 14,
                          fontWeight: stat.isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
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
// RUN CARD
// ─────────────────────────────────────────────
class _RunCard extends StatelessWidget {
  final double distanceKm;
  final String dateStr;
  final String timeStr;
  final String durStr;
  final String paceStr;

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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Column(
        children: [
          // ── running icon + title + distance ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B4B4B),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/ghm/runningperson.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Practice Run',
                    style: TextStyle(
                      color: Color(0xFF4B4B4B),
                      fontFamily: 'General Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${distanceKm.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  color: Color(0xFF4B4B4B),
                  fontFamily: 'General Sans',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── calender date   |   timeline time-of-day ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetaItem(
                svgPath: 'assets/ghm/calender.svg',
                text: dateStr,
                color: const Color(0xFF7C3EC3),
              ),
              _MetaItem(
                svgPath: 'assets/ghm/timeline.svg',
                text: timeStr,
                color: const Color(0xFF37414B),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── timeperiod duration   |   pindistance pace ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetaItem(
                svgPath: 'assets/ghm/timeperiod.svg',
                text: durStr,
                color: const Color(0xFF3E72D7),
              ),
              _MetaItem(
                svgPath: 'assets/ghm/pindistance.svg',
                text: paceStr,
                color: const Color(0xFF175BCC),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// META ITEM  (icon + text)
// ─────────────────────────────────────────────
class _MetaItem extends StatelessWidget {
  final String svgPath;
  final String text;
  final Color color;

  const _MetaItem({
    required this.svgPath,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgPath,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontFamily: 'General Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM NAV
// ─────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Color(0xFFE8EBF0), width: 0.5)),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(
            label: 'Home',
            svgPath: 'assets/ghm/runningperson.svg',
            isActive: true,
          ),
          _NavItem(
            label: 'Run',
            svgPath: 'assets/ghm/pindistance.svg',
            isActive: false,
          ),
          _NavItem(
            label: 'Leaderboard',
            svgPath: 'assets/ghm/timeline.svg',
            isActive: false,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String svgPath;
  final bool isActive;

  const _NavItem({
    required this.label,
    required this.svgPath,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    isActive ? const Color(0xFF175BCC) : const Color(0xFF888888);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontFamily: 'General Sans',
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}