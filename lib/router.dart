import 'package:techniche26/widgets/ca_bottom_nav_bar.dart';
import 'package:techniche26/view/auth/ca_auth_screen.dart';
import 'package:techniche26/view/auth/ca_register_screen.dart';
import 'package:techniche26/view/core/landing_screen.dart';
import 'package:techniche26/view/core/merch_screen.dart';
import 'package:techniche26/view/marathon/marathon_main.dart';
import 'package:techniche26/view/ghm/ghm_registration.dart';
import 'package:techniche26/view/events/events_screen.dart';
import 'package:techniche26/view/techno/papers_display.dart';
import 'package:techniche26/view/core/utilities_screen.dart';
import 'package:techniche26/view/events/workshops_screen.dart';
import 'package:techniche26/view/techno/registration_screen.dart';
import 'package:techniche26/view/home/comedy_night_screen.dart';
import 'package:techniche26/view/auth/login_screen.dart';
import 'package:techniche26/view/core/profile_screen.dart';

import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case LandingScreen.routeName:
      return _fadeRoute(const LandingScreen(), routeSettings);

    case LoginScreen.routeName:
      return _fadeRoute(const LoginScreen(), routeSettings);

    case ProfileScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ProfileScreen(),
      );

    case ComedyNightScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ComedyNightScreen(),
      );

    case CaAuthScreen.routeName:
      return _fadeRoute(const CaAuthScreen(), routeSettings);

    case CaRegisterScreen.routeName:
      return _fadeRoute(const CaRegisterScreen(), routeSettings);

    case '/auth-screen':
      return _fadeRoute(const CaAuthScreen(), routeSettings);

    case CaBottomNavBar.routeName:
      return _fadeRoute(const CaBottomNavBar(), routeSettings);

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

    case '/merch':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MerchScreen(),
      );

    // case '/schedule':
    //   return MaterialPageRoute(
    //     settings: routeSettings,
    //     builder: (_) => const LandingScreen(initialTab: 3),
    //   );

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
    
    case TechnothlonPyqScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const TechnothlonPyqScreen(),
      );

    case '/techno-registration':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const TechnoRegistrationScreen(),
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

Route _fadeRoute(Widget child, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeOutCubic;

      var fadeAnimation = animation.drive(
        Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
      );

      var scaleAnimation = animation.drive(
        Tween<double>(begin: 0.95, end: 1.0).chain(CurveTween(curve: curve)),
      );

      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

