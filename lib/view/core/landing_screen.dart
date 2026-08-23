import 'package:techniche26/view/auth/ca_auth_screen.dart';
import 'package:techniche26/widgets/app_drawer.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:techniche26/widgets/ca_bottom_nav_bar.dart';
import 'package:techniche26/view/events/events_screen.dart';
import 'package:techniche26/view/core/schedule_screen.dart';
import 'package:techniche26/view/core/legacy_screen.dart';
import 'package:techniche26/view/core/map_screen.dart';
import 'package:techniche26/controller/riverpod_controller/ca_auth_riverpod_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/widgets/bottom_nav_bar.dart';
import 'package:upgrader/upgrader.dart';
import 'package:techniche26/services/notification_service.dart';
import 'package:techniche26/providers/navigation_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:techniche26/view/eventdetailpage.dart';
import 'package:techniche26/model/events_data.dart';

import 'package:techniche26/widgets/home/home_hero_section.dart';
import 'package:techniche26/widgets/home/home_upcoming_events_section.dart';
import 'package:techniche26/widgets/home/home_campus_ambassador_section.dart';
import 'package:techniche26/widgets/home/home_merchandise_section.dart';
import 'package:techniche26/widgets/home/home_featured_events_section.dart';
import 'package:techniche26/widgets/home/home_comedy_night_section.dart';
import 'package:techniche26/features/event_reminders/presentation/reminder_picker_sheet.dart';

class LandingScreen extends ConsumerStatefulWidget {
  static const String routeName = '/landing-screen';
  final int initialTab;
  final String? initialVenue;

  const LandingScreen({
    super.key,
    this.initialTab = 2,
    this.initialVenue,
  });

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class RetroTransition extends AnimatedWidget {
  final Widget child;

  const RetroTransition({
    super.key,
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  double _clamp(double v, {double min = 0.0, double max = 1.0}) =>
      v < min ? min : (v > max ? max : v);

  @override
  Widget build(BuildContext context) {
    final double t = Curves.easeInOut.transform(animation.value);
    final double scale = 0.94 + 0.12 * t;
    final double opacity = _clamp(t);
    final Offset offset = Offset(0, (1 - t) * 18);
    final double glowPeak = (1.0 - ((t - 0.5).abs() * 2.0)).clamp(0.0, 1.0);
    final double glowOpacity = 0.06 * glowPeak;
    final double scanlineOpacity = 0.06 * glowPeak;

    return Transform.translate(
      offset: offset,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              child,
              IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: glowOpacity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan.withOpacity(0.12),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.9],
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: scanlineOpacity,
                  child: const CustomPaint(
                    painter: ScanlinePainter(),
                    size: Size.infinite,
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

class ScanlinePainter extends CustomPainter {
  const ScanlinePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.6
      ..isAntiAlias = false;
    const double spacing = 6.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LandingScreenState extends ConsumerState<LandingScreen>
    with TickerProviderStateMixin {
  static final DateTime _festStartDate = DateTime(2026, 8, 28);

  bool _isFeaturedScheduleLive = false;
  List<Map<String, dynamic>> _featuredEvents = [];
  Timer? _featuredEventsTimer;

  @override
  void initState() {
    super.initState();
    _initFeaturedEvents();
    Future.microtask(() {
      if (mounted) {
        ref.read(bottomNavSelectedIndexProvider.notifier).state =
            widget.initialTab;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        print("LandingScreen: Triggering notification setup.");
      }
      NotificationService().initializeAndHandleNotifications();
    });
  }

  void _onItemTapped(int index) {
    if (ref.read(bottomNavSelectedIndexProvider) == index) return;
    ref.read(bottomNavSelectedIndexProvider.notifier).state = index;
  }

  @override
  void dispose() {
    _featuredEventsTimer?.cancel();
    super.dispose();
  }

  Future<void> _initFeaturedEvents() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.setDefaults(const {
        "is_schedule_live": false,
        "fest_schedule_json": "{}",
      });
      await remoteConfig.fetchAndActivate();
      final isScheduleLive = remoteConfig.getBool('is_schedule_live');
      if (!isScheduleLive) return;
      final scheduleData =
          json.decode(remoteConfig.getString('fest_schedule_json'));
      if (!mounted) return;
      setState(() {
        _isFeaturedScheduleLive = true;
      });
      _updateFeaturedEvents(scheduleData);
      _featuredEventsTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _updateFeaturedEvents(scheduleData),
      );
    } catch (e) {
      debugPrint("Error fetching remote config for featured events: $e");
    }
  }

  DateTime? _parseEventDateTime(int dayNumber, dynamic timeValue) {
    if (timeValue == null) return null;
    try {
      final timeParts = timeValue.toString().split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      return DateTime(
        _festStartDate.year,
        _festStartDate.month,
        _festStartDate.day + dayNumber - 1,
        hour,
        minute,
      );
    } catch (e) {
      return null;
    }
  }

  void _updateFeaturedEvents(Map<String, dynamic> scheduleData) {
    final List<Map<String, dynamic>> featured =
        _computeFeaturedEvents(scheduleData);
    if (mounted && !_listEquals(featured, _featuredEvents)) {
      setState(() {
        _featuredEvents = featured;
      });
    }
  }

  bool _listEquals(
      List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i]['name'] != b[i]['name']) return false;
      if (a[i]['startTime'] != b[i]['startTime']) return false;
    }
    return true;
  }

  List<Map<String, dynamic>> _computeFeaturedEvents(
      Map<String, dynamic> scheduleData) {
    final DateTime now = DateTime.now();
    final List<dynamic> days = scheduleData['days'] ?? [];
    final List<({DateTime start, DateTime end, Map<String, dynamic> event})>
        parsed = [];

    for (var dayData in days) {
      final String dayTitle = dayData['title'] ?? 'Day 1';
      final int dayNumber = int.tryParse(
              dayTitle.replaceAll(RegExp(r'[^0-9]'), '')) ??
          1;
      final List<dynamic> events = dayData['events'] ?? [];
      for (var event in events) {
        final DateTime? start =
            _parseEventDateTime(dayNumber, event['startTime']);
        final DateTime? end = _parseEventDateTime(
            dayNumber, event['endTime'] ?? event['startTime']);
        if (start == null || end == null) continue;
        parsed.add((
          start: start,
          end: end,
          event: Map<String, dynamic>.from(event),
        ));
      }
    }

    parsed.sort((a, b) => a.start.compareTo(b.start));

    final List<Map<String, dynamic>> featured = [];

    for (final item in parsed) {
      if (featured.length >= 3) break;
      if (now.isAfter(item.end)) continue;
      if (!now.isBefore(item.start)) {
        featured.add(item.event);
      }
    }

    for (final item in parsed) {
      if (featured.length >= 3) break;
      if (featured.contains(item.event)) continue;
      if (now.isAfter(item.end)) continue;
      if (!now.isBefore(item.start)) continue;
      if (item.start.difference(now) <= const Duration(minutes: 120)) {
        featured.add(item.event);
      }
    }

    return featured;
  }

  Future<void> _handleAuthNavigation(BuildContext context) async {
    bool isAuth =
        await ref.read(caAuthControllerProvider).isCaUserAuthenticated();

    if (context.mounted) {
      if (isAuth) {
        Navigator.pushNamed(context, CaBottomNavBar.routeName);
      } else {
        Navigator.pushNamed(context, CaAuthScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> screens = <Widget>[
      const EventsScreen(isTab: true),
      const SchedulePage(),
      _buildHomeContent(context, isDark),
      MapScreen(initialVenue: widget.initialVenue),
      const LegacyScreen(),
    ];

    final selectedIndex = ref.watch(bottomNavSelectedIndexProvider);
    return UpgradeAlert(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF070B19) : Colors.white,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RetroTransition(animation: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<int>(selectedIndex),
            child: screens.elementAt(selectedIndex),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: GlowingBottomNavBar(
            currentIndex: selectedIndex,
            onTap: _onItemTapped,
            items: [
              GlowingBottomNavBarItem(
                  icon: Icons.event_note_sharp, label: 'Events'),
              GlowingBottomNavBarItem(icon: Icons.schedule, label: 'Schedule'),
              GlowingBottomNavBarItem(icon: Icons.home_filled, label: 'Home'),
              GlowingBottomNavBarItem(
                  icon: Icons.map_rounded, label: 'Map'),
              GlowingBottomNavBarItem(
                  icon: Icons.info_outline_rounded, label: 'About Us'),
            ],
          ),
        ),
        drawer: const AppDrawer(),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Section
          HomeHeroSection(isDark: isDark),

          // 2. Upcoming Events Section
          HomeUpcomingEventsSection(
            isDark: isDark,
            onEventTap: (title) => _navigateToEventDetail(context, title),
            onSetReminder: (title) => _setEventReminder(context, title),
          ),

           // 3. Comedy Night Section
          HomeComedyNightSection(isDark: isDark),
          const SizedBox(height: 25),

          // 4. Merchandise Section
          HomeMerchandiseSection(isDark: isDark),
          const SizedBox(height: 25),

          // 5. Campus Ambassador Section
          HomeCampusAmbassadorSection(
            isDark: isDark,
            onJoinTap: () => _handleAuthNavigation(context),
          ),
          const SizedBox(height: 25),

         

          // 6. Featured Events Section
          HomeFeaturedEventsSection(
            isDark: isDark,
            featuredEvents: _featuredDisplayEvents(),
            onEventTap: (title) => _navigateToEventDetail(context, title),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _navigateToEventDetail(BuildContext context, String eventTitle) {
    final event = findEventByTitle(eventTitle);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(
          eventTitle: eventTitle,
          event: event,
        ),
      ),
    );
  }

  void _setEventReminder(BuildContext context, String eventTitle) {
    final event = findEventByTitle(eventTitle) ?? EventDetail(title: eventTitle);
    ReminderPickerSheet.show(context, event: event);
  }

  List<Map<String, dynamic>> _featuredDisplayEvents() {
    if (!_isFeaturedScheduleLive || _featuredEvents.isEmpty) {
      final List<EventDetail> allEvents = eventData
          .expand((cat) => cat.subCategories)
          .expand((sub) => sub.events)
          .toList();
      return allEvents.take(4).map((e) => {
        'title': e.title,
        'desc': e.description ?? e.subtitle ?? '',
        'category': (e.category != null && e.category!.isNotEmpty)
            ? e.category!
            : 'Robotics',
      }).toList();
    }
    return _featuredEvents;
  }
}
