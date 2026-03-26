import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/marathon_provider.dart';
import '../../constant/appTheme.dart';

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
    final currentUser = ref.watch(marathonUsernameProvider);
    final leaderboardAsync = ref.watch(distanceLeaderboardProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(distanceLeaderboardProvider),
            color: AppTheme.primaryBlue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: screenHeight * 0.47,
                        child: SvgPicture.asset(
                          'assets/ghm/framebig.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Column(
                        children: [
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: _CircleIconButton(icon: Icons.chevron_left),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(marathonUsernameProvider.notifier).state = '';
                                      ref.read(marathonCategoryProvider.notifier).state = '6K';
                                    },
                                    child: _CircleIconButton(icon: Icons.logout, size: 22),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _buildDistanceBoard(category),
                          // Spacer at bottom for the sticky card overlay
                          const SizedBox(height: 120),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Sticky User Rank (Floating Footer) ─────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: leaderboardAsync.maybeWhen(
              data: (list) {
                final items = list.map((e) => _LeaderboardItem(e.username, e.totalDistance, 'KM')).toList();
                final myItemIndex = items.indexWhere((e) => e.username == currentUser);
                if (myItemIndex != -1) {
                  return _buildStickyRank(items[myItemIndex], myItemIndex + 1);
                }
                return const SizedBox.shrink();
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _CircleIconButton({required IconData icon, double size = 26, Color color = Colors.black}) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size),
    );
  }

  Widget _buildDistanceBoard(String category) {
    final asyncData = ref.watch(distanceLeaderboardProvider);
    return asyncData.when(
      data: (list) {
        final items = list
            .map((e) => _LeaderboardItem(e.username, e.totalDistance, 'KM'))
            .toList();
        return _buildBoard(items, category);
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (e, st) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildBoard(List<_LeaderboardItem> items, String category) {
    final currentUser = ref.watch(marathonUsernameProvider);
    final topThree = items.take(3).toList();
    final remainingItems =
        items.length > 3 ? items.sublist(3) : <_LeaderboardItem>[];

    // Find current user's item for the sticky rank
    _LeaderboardItem? myItem;
    int myRank = -1;
    for (int i = 0; i < items.length; i++) {
      if (items[i].username == currentUser) {
        myItem = items[i];
        myRank = i + 1;
        break;
      }
    }

    return Stack(
      children: [
        // ── SCROLLABLE CONTENT ──────────────────────────────────────
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = (constraints.maxWidth - 120) / 3;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (topThree.length >= 2)
                          _buildPodiumBar(topThree[1], 2, const Color(0xFF3E72D7),
                              120, 'assets/ghm/2nd.png', barWidth),
                        const SizedBox(width: 16),
                        if (topThree.isNotEmpty)
                          _buildPodiumBar(topThree[0], 1, const Color(0xFFF6BC2F),
                              180, 'assets/ghm/1st.png', barWidth),
                        const SizedBox(width: 16),
                        if (topThree.length >= 3)
                          _buildPodiumBar(topThree[2], 3, const Color(0xFF7C3EC3), 90,
                              'assets/ghm/3rd.png', barWidth),
                      ],
                    );
                  },
                ),
              ),

              // ── WHITE LIST SECTION ────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Global Leaderboard ($category)',
                      style: const TextStyle(
                        color: AppTheme.textMain,
                        fontSize: 20,
                        fontFamily: AppTheme.fontUnivers,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── LIST ─────────────────────────────────────────
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 6, bottom: 95), // Extra padding for sticky footer
                      itemCount: remainingItems.length,
                      itemBuilder: (context, index) {
                        final item = remainingItems[index];
                        return _buildLeaderboardTile(
                          item,
                          index + 4,
                          item.username == currentUser,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── STICKY RANK FOOTER ──────────────────────────────────────
        if (myItem != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyRank(myItem, myRank),
          ),
      ],
    );
  }

// ── PODIUM BAR ───────────────────────────────────────────────────────
  Widget _buildPodiumBar(_LeaderboardItem item, int rank, Color color,
      double barHeight, String trophyPath, double barWidth) {
    return SizedBox(
      width: barWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: barWidth - 8,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, size: 26, color: Colors.black),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    item.username,
                    // overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTheme.fontGeneralSans,
                      height: 1.2,
                      color: AppTheme.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Bar ──
          Container(
            width: barWidth - 4,
            height: barHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(trophyPath, width: 36),
                const SizedBox(height: 8),
                Text(
                  item.value.toStringAsFixed(2),
                  style: const TextStyle(
                      color: AppTheme.textMain,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: AppTheme.fontGeneralSans),
                ),
                const Text(
                  'KM',
                  style: TextStyle(
                    color: AppTheme.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTheme.fontGeneralSans,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── LEADERBOARD TILE (rank 4+) ───────────────────────────────────────
  Widget _buildLeaderboardTile(_LeaderboardItem item, int rank, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: isMe ? const Color(0xFFE8F0FE) : AppTheme.backgroundGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(68),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Rank badge ──
          Container(
            width: 32,
            height: 32,
            decoration: ShapeDecoration(
              color: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(88),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: AppTheme.fontGeneralSans,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Person icon (right next to rank) ──
          const Icon(Icons.account_circle, color: Color(0XFF002661), size: 36),

          const SizedBox(width: 8),

          // ── Username (expands, ellipsis if too long) ──
          Expanded(
            child: Text(
              item.username,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Distance ──
          Text(
            '${item.value.toStringAsFixed(2)} KM',
            style: const TextStyle(
              color: AppTheme.textMain,
              fontSize: 16,
              fontFamily: AppTheme.fontGeneralSans,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ── STICKY RANK FOOTER ───────────────────────────────────────────────
  Widget _buildStickyRank(_LeaderboardItem item, int rank) {
    return Container(
      height: 75,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: const RadialGradient(
          center: Alignment(0.50, 1.00),
          radius: 1.50,
          colors: [AppTheme.primaryBlue, Color(0xFF031D45)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 15.30,
            offset: Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Rank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              Text(
                '${item.value.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: AppTheme.fontGeneralSans,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontStyle: FontStyle.italic,
              fontFamily: AppTheme.fontGeneralSans,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

// ── Stripe: hollow bordered rectangle, exact Figma spec ──
  Widget _stripe() {
    return Container(
      width: 99.35,
      height: 249.98,
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 8,
            strokeAlign: BorderSide.strokeAlignCenter,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── DATA MODEL ──────────────────────────────────────────────────────────
class _LeaderboardItem {
  final String username;
  final double value;
  final String unit;
  _LeaderboardItem(this.username, this.value, this.unit);
}
