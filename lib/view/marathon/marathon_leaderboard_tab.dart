import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/marathon_provider.dart';
import '../../constant/appTheme.dart';
import '../../utils/animate_gradient_background.dart';

class MarathonLeaderboardTab extends ConsumerStatefulWidget {
  const MarathonLeaderboardTab({super.key});

  @override
  ConsumerState<MarathonLeaderboardTab> createState() =>
      _MarathonLeaderboardTabState();
}

class _MarathonLeaderboardTabState
    extends ConsumerState<MarathonLeaderboardTab> {
  @override
  Widget build(BuildContext context) {
    final category = ref.watch(marathonCategoryProvider);

    return Stack(
      children: [
        const AnimatedGradientBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Column(
              children: [
                const Text('Global Leaderboard',
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                Text('$category MARATHON',
                    style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.primaryColor,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                              blurRadius: 5,
                              color: AppTheme.primaryColor,
                              offset: Offset(0, 0)),
                        ])),
              ],
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                tooltip: 'Logout / Change Username',
                onPressed: () {
                  ref.read(marathonUsernameProvider.notifier).state = '';
                  ref.read(marathonCategoryProvider.notifier).state = '6K';
                },
              )
            ],
          ),
          body: SafeArea(
            child: _buildDistanceBoard(),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceBoard() {
    final asyncData = ref.watch(distanceLeaderboardProvider);
    return asyncData.when(
      data: (list) => _buildBoard(list
          .map((e) => _LeaderboardItem(e.username, e.totalDistance, 'km'))
          .toList()),
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      error: (e, st) => Center(
          child: Text('Error: $e',
              style: const TextStyle(
                  color: Colors.red, fontFamily: AppTheme.fontFamily))),
    );
  }

  Widget _buildBoard(List<_LeaderboardItem> items) {
    if (items.isEmpty) {
      return const Center(
          child: Text('No data yet.', style: TextStyle(color: Colors.white)));
    }

    final currentUser = ref.watch(marathonUsernameProvider);
    final myItemIndex = items.indexWhere((e) => e.username == currentUser);
    final myItem = myItemIndex != -1 ? items[myItemIndex] : null;

    return Column(
      children: [
        // List
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.cardColor,
            onRefresh: () async {
              ref.invalidate(distanceLeaderboardProvider);
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final rank = index + 1;
                final isMe = item.username == currentUser;

                // Color coding for top 3
                Color rankColor = Colors.grey[400]!;
                if (rank == 1)
                  rankColor = const Color(0xFFFFD700);
                else if (rank == 2)
                  rankColor = const Color(0xFFC0C0C0);
                else if (rank == 3) rankColor = const Color(0xFFCD7F32);

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppTheme.primaryColor.withOpacity(0.12)
                        : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: isMe
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withOpacity(0.1)),
                    boxShadow: [
                      if (isMe)
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          blurRadius: 10,
                        )
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 40,
                          child: Text('#$rank',
                              style: TextStyle(
                                  color: rankColor,
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))),
                      Expanded(
                        child: Row(
                          children: [
                            if (rank <= 3) ...[
                              Icon(Icons.emoji_events,
                                  color: rankColor, size: 16),
                              const SizedBox(width: 8),
                            ] else ...[
                              Container(
                                height: 24,
                                width: 24,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person,
                                    color: Colors.grey, size: 14),
                              ),
                            ],
                            Expanded(
                              child: Text(
                                  isMe
                                      ? 'You (${item.username})'
                                      : item.username,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: isMe
                                          ? AppTheme.primaryColor
                                          : Colors.white,
                                      fontFamily: AppTheme.fontFamily,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                      // Metric Column (Fixed/Intrinsic width)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(item.value.toStringAsFixed(2),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(item.unit,
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // Sticky My Rank
        if (myItem != null) _buildMyRankCard(myItem, myItemIndex + 1),
      ],
    );
  }

  Widget _buildMyRankCard(_LeaderboardItem item, int rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.3), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text('#$rank',
                style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('YOUR RANK',
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
                Text(item.username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.value.toStringAsFixed(2),
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              Text(item.unit,
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

class _LeaderboardItem {
  final String username;
  final double value;
  final String unit;
  _LeaderboardItem(this.username, this.value, this.unit);
}
