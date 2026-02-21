import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/marathon_provider.dart';
import '../../constant/appTheme.dart';
import '../../utils/animate_gradient_background.dart';
import 'package:intl/intl.dart';

class MarathonAllRunsScreen extends ConsumerWidget {
  const MarathonAllRunsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRunsAsync = ref.watch(allRunsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('All Practice Runs',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: allRunsAsync.when(
              data: (runs) {
                if (runs.isEmpty) {
                  return const Center(
                      child: Text('No runs logged yet.',
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: AppTheme.fontFamily)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: runs.length,
                  itemBuilder: (context, index) {
                    final run = runs[index];
                    final dateStr = DateFormat('MMM d, yyyy • h:mm a')
                        .format(run.createdAt.toLocal());

                    final int m = run.durationMinutes.floor();
                    final int s = ((run.durationMinutes - m) * 60).round();
                    final String timeStr =
                        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.18),
                            width: 1.5),
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
                            child: const Icon(Icons.directions_run,
                                color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Practice Run',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: AppTheme.fontFamily,
                                        fontWeight: FontWeight.bold)),
                                Text(dateStr,
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
                              Text('${run.distanceKm.toStringAsFixed(2)} km',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: AppTheme.fontFamily,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  '$timeStr • ${run.avgPace.toStringAsFixed(2)}/km',
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (e, st) => Center(
                  child: Text('Error loading history: $e',
                      style: const TextStyle(
                          color: Colors.red, fontFamily: AppTheme.fontFamily))),
            ),
          ),
        ],
      ),
    );
  }
}
