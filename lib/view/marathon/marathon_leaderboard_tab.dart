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
      backgroundColor: const Color(0xFF003380),
      body: Stack(
        children: [
          // ── 1. TOP BACKGROUND SVG ──────────────────────────────────
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

          // ── 2. HEADER BUTTONS ──────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, ),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 47,
                            height: 47,

                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 0.1,
                                  color: Color(0xFFB2B8BF),
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: SvgPicture.asset(
                              'assets/ghm/iconback.svg', // Path to your SVG
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout,
                        color: Colors.redAccent),
                    onPressed: () {
                      ref
                          .read(marathonUsernameProvider.notifier)
                          .state = '';
                      ref
                          .read(marathonCategoryProvider.notifier)
                          .state = '6K';
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── 3. MAIN CONTENT ────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: _buildDistanceBoard(category),
          ),
        ],
      ),
    );
  }

  // ── DATA LOADER ──────────────────────────────────────────────────────
  Widget _buildDistanceBoard(String category) {
    final asyncData = ref.watch(distanceLeaderboardProvider);
    return asyncData.when(
      data: (list) {
        final items = list
            .map((e) =>
            _LeaderboardItem(e.username, e.totalDistance, 'KM'))
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

  // ── BOARD LAYOUT ─────────────────────────────────────────────────────
  Widget _buildBoard(List<_LeaderboardItem> items, String category) {
    final currentUser = ref.watch(marathonUsernameProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final myItemIndex =
    items.indexWhere((e) => e.username == currentUser);
    final myItem =
    myItemIndex != -1 ? items[myItemIndex] : null;

    final topThree = items.take(3).toList();
    final remainingItems =
    items.length > 3 ? items.sublist(3) : <_LeaderboardItem>[];

    return Column(
      children: [
        // ── PODIUM ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (topThree.length >= 2)
                _buildPodiumBar(topThree[1], 2,
                    const Color(0xFF3E72D7), 130, 'assets/ghm/2nd.png'),
              const SizedBox(width: 12),
              if (topThree.isNotEmpty)
                _buildPodiumBar(topThree[0], 1,
                    const Color(0xFFF6BC2F), 180, 'assets/ghm/1st.png'),
              const SizedBox(width: 12),
              if (topThree.length >= 3)
                _buildPodiumBar(topThree[2], 3,
                    const Color(0xFF7C3EC3), 115, 'assets/ghm/3rd.png'),
            ],
          ),
        ),

        // ── WHITE LIST SECTION ────────────────────────────────────
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,

            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Title row with current user name pill
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 60),

                      // "Global Leaderboard" title
                      const Text(
                        'Global Leaderboard',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Univers',
                          fontWeight: FontWeight.w700,
                          height: 1.20,
                        ),
                      ),

                      // Current user name pill
                      if (currentUser.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.only(
                              top: 6, left: 6, right: 8, bottom: 6),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color(0xFFE0E0E0), width: 1),
                              borderRadius:
                              BorderRadius.circular(68),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 4),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(52),
                                  ),
                                ),
                                child: Text(
                                  currentUser,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w600,
                                    height: 1.20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(width: 60),
                    ],
                  ),
                ),

                Text(
                  '$category MARATHON',
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),

                // ── LIST ─────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(distanceLeaderboardProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 110),
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
      Color color, double height, String trophyPath) {
    return Column(
      children: [
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                item.username,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(trophyPath, width: 40),
              const SizedBox(height: 10),
              Text(
                item.value.toStringAsFixed(2),
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500),
              ),
              const Text(
                'KM',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── LEADERBOARD TILE (rank 4+) ───────────────────────────────────────
  Widget _buildLeaderboardTile(
      _LeaderboardItem item, int rank, bool isMe) {
    return Container(
      margin:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: isMe
            ? const Color(0xFFE8F0FE)
            : const Color(0xFFF3F3F3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(68),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank badge
          SizedBox(
            width: 84,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 29,
                  height: 28,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF3E72D7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(88),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      height: 1.20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Person icon — swap with Image.asset if you have a custom asset
          const Icon(Icons.account_circle,
              color: Colors.grey, size: 28),

          // Username
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(52),
              ),
            ),
            child: Text(
              item.username,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                height: 1.20,
              ),
            ),
          ),

          // Distance
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${item.value.toStringAsFixed(2)} KM',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                height: 1.20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STICKY RANK FOOTER ───────────────────────────────────────────────
  Widget _buildStickyRank(_LeaderboardItem item, int rank) {
    return SizedBox(
      height: 103,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // SVG background
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/ghm/leaderboard2.svg',
              fit: BoxFit.fill,
            ),
          ),

          // Content over SVG
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                        fontFamily: 'General Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                      ),
                    ),
                  ],
                ),
                Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w700,
                    height: 1.20,
                  ),
                ),
              ],
            ),
          ),
        ],
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