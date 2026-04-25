import 'package:techniche26/services/ca_api_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'ca_header.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = fetchLeaderboardData();
  }

  Future<List<LeaderboardEntry>> fetchLeaderboardData() async {
    try {
      final response = await CaApiService.fetchLeaderboard();

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((entry) => LeaderboardEntry.fromJson(entry)).toList();
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      throw Exception('Error fetching leaderboard: $e');
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _leaderboardFuture = fetchLeaderboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F5),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          return Column(
            children: [
              const CAHeader(title: 'LEADERBOARD'),
              Expanded(child: _buildBody(context, snapshot)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF002B5B),
        image: DecorationImage(
          image: AssetImage('assets/ghm/frame3.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFAFAFAF)),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Center(
            child: Text(
              'CA LEADERBOARD',
              style: TextStyle(
                color: Color(0XFF232930),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Univers',
                height: 1.2,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AsyncSnapshot<List<LeaderboardEntry>> snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Connection Error',
              style: TextStyle(
                fontFamily: 'Univers',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _onRefresh,
              child: const Text('Retry',
                  style: TextStyle(color: Color(0xFF002B5B))),
            ),
          ],
        ),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF002B5B),
          strokeWidth: 3,
        ),
      );
    }

    final leaderboardData = snapshot.data!;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF002B5B),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: TopThreeWidget(
                topThree: leaderboardData.take(3).toList(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 4),
                child: Row(
                  children: [
                    const Icon(Icons.format_list_numbered_rounded,
                        size: 20, color: Color(0xFF6D7985)),
                    const SizedBox(width: 8),
                    const Text(
                      'GLOBAL RANKINGS',
                      style: TextStyle(
                        fontFamily: 'Univers',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Color(0xFF6D7985),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = leaderboardData[index];
                  return LeaderboardListTile(
                    position: index + 1,
                    entry: entry,
                  );
                },
                childCount: leaderboardData.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class TopThreeWidget extends StatelessWidget {
  final List<LeaderboardEntry> topThree;

  const TopThreeWidget({
    Key? key,
    required this.topThree,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 40) / 3;

        return SizedBox(
          width: constraints.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (topThree.length > 1)
                SizedBox(
                  width: itemWidth,
                  child: PodiumItem(
                    entry: topThree[1],
                    position: 2,
                    height: 120.0,
                  ),
                ),
              if (topThree.isNotEmpty)
                SizedBox(
                  width: itemWidth,
                  child: PodiumItem(
                    entry: topThree[0],
                    position: 1,
                    height: 160.0,
                  ),
                ),
              if (topThree.length > 2)
                SizedBox(
                  width: itemWidth,
                  child: PodiumItem(
                    entry: topThree[2],
                    position: 3,
                    height: 100.0,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int position;
  final double height;

  const PodiumItem({
    Key? key,
    required this.entry,
    required this.position,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatar(),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            entry.name,
            style: const TextStyle(
              fontFamily: 'Univers',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0XFF232930),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF002B5B), Color(0xFF001A3D)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF002B5B).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: Text(
              '${entry.points}\nPTS',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Univers',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _getPositionColor(), width: 2),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF5F5F5),
            child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontFamily: 'Univers',
                fontWeight: FontWeight.bold,
                color: Color(0xFF002B5B),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getPositionColor(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '#$position',
              style: const TextStyle(
                fontFamily: 'Univers',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getPositionColor() {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF002B5B);
    }
  }
}

class LeaderboardListTile extends StatelessWidget {
  final int position;
  final LeaderboardEntry entry;

  const LeaderboardListTile({
    Key? key,
    required this.position,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: position <= 3
                ? _getPositionColor().withOpacity(0.1)
                : const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              position.toString(),
              style: TextStyle(
                fontFamily: 'Univers',
                fontWeight: FontWeight.bold,
                color: position <= 3
                    ? _getPositionColor()
                    : const Color(0xFF6D7985),
              ),
            ),
          ),
        ),
        title: Text(
          entry.name,
          style: const TextStyle(
            fontFamily: 'General Sans',
            fontWeight: FontWeight.w700,
            color: Color(0XFF232930),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF002B5B).withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${entry.points} PTS',
            style: const TextStyle(
              fontFamily: 'Univers',
              color: Color(0xFF002B5B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Color _getPositionColor() {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF002B5B);
    }
  }
}

class LeaderboardEntry {
  final String name;
  final int points;

  const LeaderboardEntry({
    required this.name,
    required this.points,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'] as String,
      points: json['points'] as int,
    );
  }
}
