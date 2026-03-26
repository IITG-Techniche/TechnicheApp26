import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/marathon_provider.dart';
import 'marathon_dashboard_tab.dart';
import 'marathon_enrollment_view.dart';
import 'marathon_run_tab.dart';
 // Fixed typo if needed, ensure path is correct
import 'marathon_leaderboard_tab.dart';
import '../../constant/appTheme.dart';

class MarathonMainScreen extends ConsumerStatefulWidget {
  static const String routeName = '/marathon';
  const MarathonMainScreen({super.key});

  @override
  ConsumerState<MarathonMainScreen> createState() => _MarathonMainScreenState();
}

class _MarathonMainScreenState extends ConsumerState<MarathonMainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Start GPS acquisition early — when the marathon screen loads,
    // not just when the Run tab is opened. This gives GPS time to
    // acquire a fix and cache map tiles before the user starts running.
    Future.microtask(() {
      ref.read(liveRunProvider.notifier).enableTrackingIfPermitted();
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = ref.watch(marathonUsernameProvider);

    if (username.isEmpty) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: MarathonEnrollmentView(),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          MarathonDashboardTab(),
          MarathonRunTab(),
          MarathonLeaderboardTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNavItem(0, 'Home', Icons.home_filled, Icons.home_outlined),
            _buildNavItem(1, 'Run', Icons.directions_run, Icons.directions_run_outlined),
            _buildNavItem(2, 'Leaderboard', Icons.leaderboard, Icons.leaderboard_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData activeIcon, IconData inactiveIcon) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon - Fixed 20x20 per Figma
              SizedBox(
                width: 20,
                height: 20,
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  size: 20,
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2), // Spacing from Figma
              // Label Text
              SizedBox(
                width: 115,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                    fontSize: 12,
                    fontFamily: AppTheme.fontGeneralSans,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    height: 1.33,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}