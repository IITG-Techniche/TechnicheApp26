import 'package:flutter/material.dart';

// Auth
import 'package:techniche26/view/auth/ca_auth_screen.dart';
import 'package:techniche26/view/auth/ca_register_screen.dart';
import 'package:techniche26/view/auth/login_screen.dart';

// CA
import 'package:techniche26/view/ca/homescreen.dart';
import 'package:techniche26/widgets/ca_bottom_nav_bar.dart';

// Core
import 'package:techniche26/view/core/landing_screen.dart';
import 'package:techniche26/view/core/legacy_screen.dart';
import 'package:techniche26/view/core/map_screen.dart';
import 'package:techniche26/view/core/merch_screen.dart';
import 'package:techniche26/view/core/onboarding_screen.dart';
import 'package:techniche26/view/core/profile_screen.dart';
import 'package:techniche26/view/core/schedule_screen.dart';
import 'package:techniche26/view/core/splash_screen.dart';
import 'package:techniche26/view/core/utilities_screen.dart';

// Events
import 'package:techniche26/view/events/events_screen.dart';
import 'package:techniche26/view/events/sub_category_screen.dart';
import 'package:techniche26/view/events/workshops_screen.dart';

// GHM
import 'package:techniche26/view/ghm/ghm_payment_screen.dart';
import 'package:techniche26/view/ghm/ghm_registration.dart';

// Home
import 'package:techniche26/view/home/comedy_night_screen.dart';

// Marathon
import 'package:techniche26/view/marathon/marathon_all_runs_screen.dart';
import 'package:techniche26/view/marathon/marathon_main.dart';

// Rewards
import 'package:techniche26/view/rewards/rewards_store_screen.dart';

// Techno
import 'package:techniche26/view/techno/papers_display.dart';
import 'package:techniche26/view/techno/payment_screen.dart';
import 'package:techniche26/view/techno/registration_screen.dart';

// Models
import 'package:techniche26/model/events_data.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    // Core Routes
    case SplashScreen.routeName:
      return _fadeRoute(const SplashScreen(), routeSettings);

    case LandingScreen.routeName:
      final args = routeSettings.arguments;
      int initialTab = 2;
      String? initialVenue;
      if (args is Map<String, dynamic>) {
        initialTab = args['initialTab'] ?? 2;
        initialVenue = args['initialVenue'];
      } else if (args is int) {
        initialTab = args;
      }
      return _fadeRoute(
        LandingScreen(initialTab: initialTab, initialVenue: initialVenue),
        routeSettings,
      );

    case OnboardingScreen.routeName:
      return _fadeRoute(const OnboardingScreen(), routeSettings);

    case ProfileScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ProfileScreen(),
      );

    case LegacyPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const LegacyPage(),
      );

    case SchedulePage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SchedulePage(),
      );

    case MapScreen.routeName:
      final args = routeSettings.arguments;
      String? initialVenue;
      if (args is String) {
        initialVenue = args;
      } else if (args is Map<String, dynamic>) {
        initialVenue = args['initialVenue'];
      }
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => MapScreen(initialVenue: initialVenue),
      );

    case UtilitiesScreen.routeName:
    case '/utilities':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const UtilitiesScreen(),
      );

    case MerchScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MerchScreen(),
      );

    // Auth Routes
    case LoginScreen.routeName:
      return _fadeRoute(const LoginScreen(), routeSettings);

    case CaAuthScreen.routeName:
    case '/auth-screen':
      return _fadeRoute(const CaAuthScreen(), routeSettings);

    case CaRegisterScreen.routeName:
      return _fadeRoute(const CaRegisterScreen(), routeSettings);

    // CA Dashboard & Home
    case CaBottomNavBar.routeName:
    case '/ca-dashboard':
      return _fadeRoute(const CaBottomNavBar(), routeSettings);

    case Homescreen.routeName:
    case '/ca-home':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Homescreen(),
      );

    // Events & Workshops Routes
    case EventsScreen.routeName:
    case '/events':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const EventsScreen(),
      );

    case WorkshopsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const WorkshopsScreen(),
      );


    case SubCategoryScreen.routeName:
      final args = routeSettings.arguments as Map<String, dynamic>?;
      if (args != null &&
          args.containsKey('categoryTitle') &&
          args.containsKey('subCategories')) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => SubCategoryScreen(
            categoryTitle: args['categoryTitle'] as String,
            subCategories: args['subCategories'] as List<SubCategory>,
          ),
        );
      }
      return _errorRoute(routeSettings);

    // Fest Home & Special Events
    case ComedyNightScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ComedyNightScreen(),
      );

    // GHM Routes
    case GHMRegistrationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const GHMRegistrationScreen(),
      );

    case GHMPaymentScreen.routeName:
      final args = routeSettings.arguments as Map<String, dynamic>?;
      if (args != null &&
          args.containsKey('paymentUrl') &&
          args.containsKey('onPaymentSuccess')) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => GHMPaymentScreen(
            paymentUrl: args['paymentUrl'] as String,
            onPaymentSuccess: args['onPaymentSuccess'] as Function(),
          ),
        );
      }
      return _errorRoute(routeSettings);

    // Marathon Routes
    case MarathonMainScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MarathonMainScreen(),
      );

    case MarathonAllRunsScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MarathonAllRunsScreen(),
      );

    // Techno & Technothlon Routes
    case TechnothlonPyqScreen.routeName:
    case '/techno-pyq':
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const TechnothlonPyqScreen(),
      );

    case TechnoRegistrationScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const TechnoRegistrationScreen(),
      );

    case PaymentScreen.routeName:
    case '/payment':
      final args = routeSettings.arguments as Map<String, dynamic>?;
      if (args != null &&
          args.containsKey('paymentUrl') &&
          args.containsKey('onPaymentSuccess')) {
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => PaymentScreen(
            paymentUrl: args['paymentUrl'] as String,
            onPaymentSuccess: args['onPaymentSuccess'] as Function(String),
          ),
        );
      }
      return _errorRoute(routeSettings);

    // Rewards Routes
    case RewardsStoreScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const RewardsStoreScreen(),
      );

    default:
      return _errorRoute(routeSettings);
  }
}

Route _errorRoute(RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => const Scaffold(
      body: Center(
        child: Text('This page does not exist'),
      ),
    ),
  );
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
