import 'package:techniche26/constant/global.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _leaderboardFuture;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = fetchLeaderboardData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<List<LeaderboardEntry>> fetchLeaderboardData() async {
    const uri = GlobalVariables.baseUrl;
    try {
      final response = await http.get(
        Uri.parse('$uri/catasksupload/leaderboard'),
      );

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
    try {
      final newData = await fetchLeaderboardData();
      setState(() {
        _leaderboardFuture = Future.value(newData);
      });
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<LeaderboardEntry>>(
          future: _leaderboardFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load leaderboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: _onRefresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final leaderboardData = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    centerTitle: true,
                    title: const Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  SliverToBoxAdapter(
                    child: TopThreeWidget(
                      topThree: leaderboardData.take(3).toList(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'All Rankings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  SliverList(
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class RefreshController {
  void refreshCompleted() {}
  void refreshFailed() {}
  void dispose() {}
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
        final isSmallScreen = constraints.maxWidth < 600;
        final itemWidth =
            (constraints.maxWidth - 48) / 3; // Account for padding

        return Container(
          padding: const EdgeInsets.all(16.0),
          width: constraints.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (topThree.length > 1)
                SizedBox(
                  width: itemWidth,
                  child: PodiumItem(
                    entry: topThree[1],
                    position: 2,
                    height: isSmallScreen ? 140.0 : 180.0,
                  ),
                ),
              if (topThree.isNotEmpty)
                SizedBox(
                  width: itemWidth,
                  child: PodiumItem(
                    entry: topThree[0],
                    position: 1,
                    height: isSmallScreen ? 160.0 : 200.0,
                  ),
                ),
              if (topThree.length > 2)
                SizedBox(
                  width: itemWidth,
                  child: PodiumItem(
                    entry: topThree[2],
                    position: 3,
                    height: isSmallScreen ? 120.0 : 160.0,
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

  Color _getPositionColor() {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade300;
      case 3:
        return const Color.fromARGB(255, 105, 90, 84);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: _getPositionColor(),
          child: Text(
            '$position',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.name,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${entry.points} pts',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 70, // Reduced width from 80 to 70
          height: height,
          decoration: BoxDecoration(
            color: _getPositionColor(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
      ],
    );
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Text(
            position.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        title: Text(
          entry.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${entry.points} pts',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
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
