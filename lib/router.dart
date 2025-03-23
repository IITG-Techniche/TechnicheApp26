import 'package:amazon_clone/view/auth/authScreen.dart';
import 'package:amazon_clone/utils/bottomNavBar.dart';
import 'package:amazon_clone/view/landing_screen.dart';
import 'package:amazon_clone/view/marathon_screen.dart';
import 'package:amazon_clone/view/techniche_screen.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case LandingScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const LandingScreen(),
      );

    case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AuthScreen(),
      );

    case BottomNavBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BottomNavBar(),
      );

    case MarathonScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MarathonScreen(),
      );

    case TechnicheScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const TechnicheScreen(),
      );

    // Include all your other routes here

    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('This page does not exist'),
          ),
        ),
      );
  }
}
