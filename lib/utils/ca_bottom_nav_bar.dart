//import 'package:amazon_clone/view/auth/authScreen.dart';
import 'package:amazon_clone/utils/bottom_nav_bar.dart';
import 'package:amazon_clone/view/ca/homescreen.dart';
import 'package:amazon_clone/view/ca/leaderboard.dart';
import 'package:amazon_clone/view/ca/profilescreen.dart';
import 'package:amazon_clone/view/ca/taskscreen.dart';
import 'package:flutter/material.dart';

class CaBottomNavBar extends StatefulWidget {
  const CaBottomNavBar({super.key});
  static const String routeName = '/navbar';
  @override
  State<CaBottomNavBar> createState() => _CaBottomNavBarState();
}

class _CaBottomNavBarState extends State<CaBottomNavBar> {
  List<Widget> screens = [
    Homescreen(),
    TasksScreen(),
    LeaderboardScreen(),
    ProfileScreen()
  ];
  int screen_index = 0;

  updateScreen(int index) {
    setState(() {
      screen_index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[screen_index],
      bottomNavigationBar: GlowingBottomNavBar(
        onTap: updateScreen,
        currentIndex: screen_index,
        items: [
          GlowingBottomNavBarItem(
            icon: Icons.home_filled,
            label: "Home",
          ),
          GlowingBottomNavBarItem(
            icon: Icons.task_alt_outlined,
            label: "Tasks",
          ),
          GlowingBottomNavBarItem(
            icon: Icons.leaderboard_sharp,
            label: "Leaderboard",
          ),
          GlowingBottomNavBarItem(
            icon: Icons.account_circle_sharp,
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
