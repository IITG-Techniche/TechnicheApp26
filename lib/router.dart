import 'package:techniche26/utils/ca_bottom_nav_bar.dart';
import 'package:techniche26/view/auth/ca_auth_screen.dart';
import 'package:techniche26/view/landing_screen.dart';
import 'package:techniche26/view/merch_screen.dart';
import 'package:techniche26/view/marathon/marathon_main.dart';
import 'package:techniche26/view/ghm/ghm_registration.dart';
import 'package:techniche26/view/techniche_screen.dart';
import 'package:techniche26/view/techno/papers_display.dart';
import 'package:techniche26/view/utilities_screen.dart';
import 'package:techniche26/view/workshops_screen.dart';
import 'package:techniche26/view/techno/registration_screen.dart';

import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case LandingScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const LandingScreen(),
      );

    case CaAuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CaAuthScreen(),
      );

    // Keep old route for backward compatibility
    case '/auth-screen':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CaAuthScreen(),
      );

    case CaBottomNavBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const CaBottomNavBar(),
      );

    case GHMRegistrationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const GHMRegistrationScreen(),
      );
    case MarathonMainScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MarathonMainScreen(),
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

    case '/techno-registration':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const RegistrationScreen(),
      );

    case '/merch':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MerchScreen(),
      );

    case '/schedule':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const LandingScreen(initialTab: 3),
      );

    case UtilitiesScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const LandingScreen(initialTab: 4),
      );

    case WorkshopsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const WorkshopsScreen(),
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
