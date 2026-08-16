import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/event_points_provider.dart';

class RewardsStoreScreen extends ConsumerStatefulWidget {
  static const String routeName = '/rewards-store';
  const RewardsStoreScreen({super.key});

  @override
  ConsumerState<RewardsStoreScreen> createState() => _RewardsStoreScreenState();
}

class _RewardsStoreScreenState extends ConsumerState<RewardsStoreScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(eventPointsProvider.notifier).fetchUserPoints();
      ref.read(eventPointsProvider.notifier).fetchCatalog();
    });
  }

  void _onRedeemPressed(RewardItem item) async {
    final state = ref.read(eventPointsProvider);

    if (state.totalPoints < item.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Need ${item.cost - state.totalPoints} more points to redeem ${item.title}!',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Redeem Reward?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Deduct ${item.cost} points for ${item.title}?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676)),
            child: const Text('Redeem', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final redemption = await ref
          .read(eventPointsProvider.notifier)
          .redeemReward(context: context, rewardId: item.id);

      if (redemption != null && mounted) {
        _showTicketDialog(redemption);
      }
    }
  }

  void _showTicketDialog(RedemptionRecord redemption) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2_rounded, color: Colors.greenAccent, size: 80),
            const SizedBox(height: 12),
            Text(
              redemption.rewardTitle,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Show this pass code at Techniche Entry Gate',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.greenAccent),
              ),
              child: SelectableText(
                redemption.redemptionCode,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close Pass', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventPointsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Techniche Rewards Hub'),
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(eventPointsProvider.notifier).fetchUserPoints();
              ref.read(eventPointsProvider.notifier).fetchCatalog();
            },
          ),
        ],
      ),
      body: state.isLoading && state.catalog.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(eventPointsProvider.notifier).fetchUserPoints();
                await ref.read(eventPointsProvider.notifier).fetchCatalog();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Points Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF238636), Color(0xFF1E6830)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Techniche Points Balance',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: Colors.amber, size: 36),
                              const SizedBox(width: 8),
                              Text(
                                '${state.totalPoints} Pts',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                            label: const Text('Earn More Points at Events'),
                            onPressed: () => Navigator.pushNamed(context, '/event-checkin'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Featured Reward: Comedy Night Free Pass
                    const Text(
                      '🎭 Featured Reward',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.withOpacity(0.6), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.theater_comedy_rounded, color: Colors.amber, size: 28),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Free Comedy Night Entry Pass',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '500 Points Required',
                                      style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Guaranteed free entry pass to Techniche official Comedy Night featuring top artists!',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.totalPoints >= 500
                                    ? const Color(0xFF00E676)
                                    : Colors.grey[800],
                                foregroundColor: state.totalPoints >= 500
                                    ? Colors.black
                                    : Colors.white38,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                final comedyItem = state.catalog.firstWhere(
                                  (item) => item.id == 'COMEDY_NIGHT_PASS',
                                  orElse: () => RewardItem(
                                    id: 'COMEDY_NIGHT_PASS',
                                    title: 'Free Comedy Night Entry Pass',
                                    description: '',
                                    cost: 500,
                                    category: 'TICKET',
                                    icon: 'theater_comedy',
                                  ),
                                );
                                _onRedeemPressed(comedyItem);
                              },
                              child: Text(
                                state.totalPoints >= 500
                                    ? 'Claim Free Comedy Pass (500 Pts)'
                                    : 'Need ${500 - state.totalPoints} More Points',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Goodies Catalog
                    const Text(
                      '🎁 Goodies & Perks Catalog',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.catalog.length,
                      itemBuilder: (ctx, index) {
                        final item = state.catalog[index];
                        final bool canAfford = state.totalPoints >= item.cost;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161B22),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF30363D)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF21262D),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF58A6FF)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.cost} Points',
                                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canAfford ? const Color(0xFF238636) : Colors.grey[800],
                                  foregroundColor: canAfford ? Colors.white : Colors.grey,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                onPressed: () => _onRedeemPressed(item),
                                child: Text(canAfford ? 'Redeem' : '${item.cost} Pts'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // My Claimed Tickets Section
                    if (state.redemptions.isNotEmpty) ...[
                      const Text(
                        '🎟️ My Claimed Tickets & QR Passes',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.redemptions.length,
                        itemBuilder: (ctx, index) {
                          final red = state.redemptions[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161B22),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF30363D)),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.qr_code_rounded, color: Colors.greenAccent),
                              title: Text(red.rewardTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text('Code: ${red.redemptionCode}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                              trailing: IconButton(
                                icon: const Icon(Icons.open_in_new_rounded, color: Colors.white70),
                                onPressed: () => _showTicketDialog(red),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
