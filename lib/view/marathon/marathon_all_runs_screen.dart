import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/marathon_provider.dart';
import '../../constant/appTheme.dart';
import 'package:intl/intl.dart';

class MarathonAllRunsScreen extends ConsumerWidget {
  const MarathonAllRunsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRunsAsync = ref.watch(allRunsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        title: const Text(
          'All Practice Runs',
          style: TextStyle(
            color: AppTheme.primaryBlue,
            fontFamily: AppTheme.fontUnivers,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppTheme.primaryBlue, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: allRunsAsync.when(
        data: (runs) {
          if (runs.isEmpty) {
            return const Center(
              child: Text(
                'No runs logged yet.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontFamily: AppTheme.fontGeneralSans,
                ),
              ),
            );
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_run,
                          color: AppTheme.primaryBlue, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Practice Run',
                            style: TextStyle(
                              color: AppTheme.textMain,
                              fontFamily: AppTheme.fontUnivers,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontFamily: AppTheme.fontGeneralSans,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${run.distanceKm.toStringAsFixed(2)} KM',
                          style: const TextStyle(
                            color: AppTheme.textMain,
                            fontFamily: AppTheme.fontGeneralSans,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$timeStr • ${run.avgSpeed.toStringAsFixed(1)} km/h',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontFamily: AppTheme.fontGeneralSans,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
        error: (e, st) => Center(
          child: Text(
            'Error loading history: $e',
            style: const TextStyle(
              color: Colors.red,
              fontFamily: AppTheme.fontGeneralSans,
            ),
          ),
        ),
      ),
    );
  }
}
