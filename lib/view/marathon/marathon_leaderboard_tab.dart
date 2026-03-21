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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Stack(
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
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

                  // Logout button (same style)
                  GestureDetector(
                    onTap: () {
                      ref.read(marathonUsernameProvider.notifier).state = '';
                      ref.read(marathonCategoryProvider.notifier).state = '6K';
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: _buildDistanceBoard(category),
          ),
        ],
      ),
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
      loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white)),
      error: (e, st) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.red))),
    );
  }
  Widget _buildBoard(List<_LeaderboardItem> items, String category) {
    final currentUser = ref.watch(marathonUsernameProvider);
    final myItemIndex = items.indexWhere((e) => e.username == currentUser);
    final myItem = myItemIndex != -1 ? items[myItemIndex] : null;

    final topThree = items.take(3).toList();
    final remainingItems =
    items.length > 3 ? items.sublist(3) : <_LeaderboardItem>[];

    return Column(
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
                    _buildPodiumBar(topThree[1], 2,
                        const Color(0xFF3E72D7), 120, 'assets/ghm/2nd.png', barWidth),
                  const SizedBox(width: 16),
                  if (topThree.isNotEmpty)
                    _buildPodiumBar(topThree[0], 1,
                        const Color(0xFFF6BC2F), 180, 'assets/ghm/1st.png', barWidth),
                  const SizedBox(width: 16),
                  if (topThree.length >= 3)
                    _buildPodiumBar(topThree[2], 3,
                        const Color(0xFF7C3EC3), 90, 'assets/ghm/3rd.png', barWidth),

                ],
              );
            },
          ),
        ),

        // ── WHITE LIST SECTION ────────────────────────────────────
        Expanded(
          child: Container(
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
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(distanceLeaderboardProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 6, bottom: 110),
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
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── STICKY RANK FOOTER ────────────────────────────────────
        if (myItem != null) _buildStickyRank(myItem, myItemIndex + 1),
      ],
    );
  }

// ── PODIUM BAR ───────────────────────────────────────────────────────
  Widget _buildPodiumBar(_LeaderboardItem item, int rank,
      Color color, double barHeight, String trophyPath, double barWidth) {
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
                        height : 1.2,
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
                    fontFamily: AppTheme.fontGeneralSans
                  ),
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
  Widget _buildLeaderboardTile(
      _LeaderboardItem item, int rank, bool isMe) {
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
      height: 103,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        gradient: RadialGradient(
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

        children: [
          const SizedBox(width: 100),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Rank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.20,
                ),
              ),
              Text(
                '${item.value.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: AppTheme.fontGeneralSans,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontStyle: FontStyle.italic,
              fontFamily: AppTheme.fontGeneralSans,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }}

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

// ── DATA MODEL ──────────────────────────────────────────────────────────
class _LeaderboardItem {
  final String username;
  final double value;
  final String unit;
  _LeaderboardItem(this.username, this.value, this.unit);
}