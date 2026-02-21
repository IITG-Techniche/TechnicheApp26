import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/marathon_provider.dart';
import '../../model/marathon_models.dart';
import '../../constant/appTheme.dart';
import '../../utils/animate_gradient_background.dart';
import 'package:intl/intl.dart';
import 'marathon_all_runs_screen.dart';

class MarathonDashboardTab extends ConsumerWidget {
  const MarathonDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressStatsProvider);
    final recentRunsAsync = ref.watch(recentRunsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Dashboard',
            style: TextStyle(
                color: AppTheme.primaryColor,
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                      blurRadius: 10,
                      color: AppTheme.primaryColor,
                      offset: Offset(0, 0)),
                ])),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.of(context).pop(), // App navigation
        ),
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: progressAsync.when(
              data: (stats) {
                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  backgroundColor: AppTheme.cardColor,
                  onRefresh: () async {
                    ref.invalidate(progressStatsProvider);
                    ref.invalidate(recentRunsProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top 4 stats cards
                        Row(
                          children: [
                            Expanded(
                                child: _buildStatCard('STREAK',
                                    '${stats.streak} Days', Colors.cyan[200]!)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildStatCard(
                                    'THIS WEEK',
                                    '${stats.weeklyKm.toStringAsFixed(2)} km',
                                    Colors.teal[300]!)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: _buildStatCard(
                                    'AVG PACE',
                                    stats.weeklyPace.toStringAsFixed(2),
                                    Colors.blue[300]!)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildStatCard(
                                    ' IMPROVEMENT',
                                    '+${stats.improvement}%',
                                    AppTheme.primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildChartCard('Daily Distance',
                            '${stats.weeklyKm.toStringAsFixed(2)} km',
                            isBarChart: true, dailyStats: stats.dailyStats),
                        const SizedBox(height: 24),

                        // Last 5 Runs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Last 5 Runs',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const MarathonAllRunsScreen()));
                              },
                              child: const Text('See All',
                                  style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontFamily: AppTheme.fontFamily)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        recentRunsAsync.when(
                          data: (runs) {
                            if (runs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(
                                    child: Text('No runs logged yet.',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontFamily: AppTheme.fontFamily))),
                              );
                            }

                            return Column(
                              children: runs.map((run) {
                                final dateStr = DateFormat('MMM d • h:mm a')
                                    .format(run.createdAt.toLocal());
                                final int m = run.durationMinutes.floor();
                                final int s =
                                    ((run.durationMinutes - m) * 60).round();
                                final String timeStr =
                                    '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

                                return _buildDummyRunLog(
                                  'Practice Run',
                                  dateStr,
                                  '${run.distanceKm.toStringAsFixed(2)} km',
                                  '$timeStr • ${run.avgPace.toStringAsFixed(2)}/km',
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor)),
                          error: (e, st) => Text('Error loading runs: $e',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontFamily: AppTheme.fontFamily)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (e, st) => Center(
                  child: Text('Error loading stats: $e',
                      style: const TextStyle(
                          color: Colors.red, fontFamily: AppTheme.fontFamily))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String mainValue, Color accentLine) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(mainValue,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, String val,
      {required bool isBarChart, required List<DailyStat> dailyStats}) {
    // Find max value to scale the chart
    double maxVal = 0;
    if (isBarChart) {
      maxVal =
          dailyStats.map((e) => e.distance).fold(0, (a, b) => a > b ? a : b);
    } else {
      maxVal = dailyStats.map((e) => e.pace).fold(0, (a, b) => a > b ? a : b);
    }
    if (maxVal == 0) maxVal = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  letterSpacing: 1.1)),
          const SizedBox(height: 4),
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          // Real Data Graph
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: dailyStats.map((stat) {
              if (isBarChart) {
                // Scale height up to 80, clamp to prevent vertical overflow within 220 height
                double h = (stat.distance / maxVal) * 80;
                h = h.clamp(2.0, 80.0);
                return Flexible(child: _buildBar(h, stat.isToday));
              } else {
                // For pace trend, we show dots at heights
                double h = (stat.pace / maxVal) * 80;
                h = h.clamp(0.0, 80.0);
                return Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          height: 8,
                          width: 8,
                          margin: EdgeInsets.only(bottom: h),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: stat.isToday
                                  ? AppTheme.primaryColor
                                  : AppTheme.primaryColor.withOpacity(0.4))),
                      const SizedBox(height: 4),
                    ],
                  ),
                );
              }
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: dailyStats.map((stat) {
              return Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(stat.dayName[0], // First letter
                      style: TextStyle(
                          color: stat.isToday
                              ? AppTheme.primaryColor
                              : Colors.grey,
                          fontSize: 10,
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: stat.isToday
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildBar(double height, bool isActive) {
    return Container(
      height: height,
      width: 16,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2)
              ]
            : [],
      ),
    );
  }

  Widget _buildDummyRunLog(
      String title, String date, String dist, String pace) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.directions_run, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.bold)),
                Text(date,
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(dist,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.bold)),
              Text(pace,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
