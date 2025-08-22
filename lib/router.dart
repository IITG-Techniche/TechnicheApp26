import 'package:amazon_clone/utils/ca_bottom_nav_bar.dart';
import 'package:amazon_clone/view/auth/authScreen.dart';
import 'package:amazon_clone/view/landing_screen.dart';
import 'package:amazon_clone/view/merch_screen.dart';
import 'package:amazon_clone/view/ghm/marathon_screen.dart';
import 'package:amazon_clone/view/ghm/ghm_selection.dart';
import 'package:amazon_clone/view/ghm/ghm_registration.dart';
import 'package:amazon_clone/view/techniche_screen.dart';
import 'package:amazon_clone/view/schedule_screen.dart';
import 'package:amazon_clone/view/techno/papers_display.dart';
import 'package:amazon_clone/view/utilities_screen.dart';

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

    case CaBottomNavBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CaBottomNavBar(),
      );

    case GHMScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const GHMScreen(),
      );
    case GHMRegistrationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const GHMRegistrationScreen(),
      );

    case MarathonScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MarathonScreen(),
      );

    case EventsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const EventsScreen(),
      );

    case TechnothlonScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const TechnothlonScreen(),
      );

    case '/merch':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MerchScreen(),
      );

    case '/schedule':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SchedulePage(),
      );

    case UtilitiesScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const UtilitiesScreen(),
      );

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
