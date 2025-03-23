//import 'package:amazon_clone/view/auth/authScreen.dart';
import 'package:amazon_clone/view/homescreen.dart';
import 'package:amazon_clone/view/leaderboard.dart';
import 'package:amazon_clone/view/profilescreen.dart';
import 'package:amazon_clone/view/taskscreen.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  static const String routeName = '/navbar';
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
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
      bottomNavigationBar: BottomNavigationBar(
        onTap: updateScreen,
        currentIndex: screen_index,
        type: BottomNavigationBarType.fixed, // Add this line
        selectedItemColor: Colors.amber, // Add this line
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.workspace_premium_sharp,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.task_alt_sharp,
            ),
            label: "Tasks",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.leaderboard_sharp,
            ),
            label: "Leaderboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_sharp,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
