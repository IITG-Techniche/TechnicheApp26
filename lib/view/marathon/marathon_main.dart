import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/marathon_provider.dart';
import 'marathon_dashboard_tab.dart';
import 'marathon_enrollment_view.dart';
import 'marathon_run_tab.dart';
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
  Widget build(BuildContext context) {
    final username = ref.watch(marathonUsernameProvider);

    // If not enrolled, force them to Home tab but show Enrollment View
    Widget currentTab;
    if (_currentIndex == 0) {
      currentTab = username.isEmpty
          ? const MarathonEnrollmentView()
          : const MarathonDashboardTab();
    } else if (_currentIndex == 1) {
      currentTab = username.isEmpty
          ? const MarathonEnrollmentView()
          : const MarathonRunTab();
    } else {
      currentTab = username.isEmpty
          ? const MarathonEnrollmentView()
          : const MarathonLeaderboardTab();
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: currentTab,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.scaffoldBackgroundColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: AppTheme.fontFamily,
            letterSpacing: 1.2,
          ),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run_outlined),
              activeIcon: Icon(Icons.directions_run),
              label: 'RUN',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'LEADERBOARD',
            ),
          ],
        ),
      ),
    );
  }
}