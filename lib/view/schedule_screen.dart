import 'package:techniche26/utils/animate_gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:techniche26/view/landing_screen.dart';

const Map<String, Map<String, dynamic>> categoryStyles = {
  'Robotics': {'icon': Icons.smart_toy_outlined, 'color': Color(0xff00ffdd)},
  'Hackathons': {'icon': Icons.code, 'color': Color(0xff7f00ff)},
  'Workshops': {'icon': Icons.build_outlined, 'color': Color(0xfff9ff00)},
  'Techno': {'icon': Icons.lightbulb_outline, 'color': Color(0xff00e5ff)},
  'Tech-Expo': {'icon': Icons.camera_alt_outlined, 'color': Color(0xff00ff87)},
  'Lecture Series': {
    'icon': Icons.mic_external_on_outlined,
    'color': Color(0xffff4081)
  },
  'Entertainment': {
    'icon': Icons.music_note_outlined,
    'color': Color(0xffff9100)
  },
  'Nexus': {'icon': Icons.people_outline, 'color': Color(0xff00b0ff)},
  'Funniche': {'icon': Icons.gamepad_outlined, 'color': Color(0xffd500f9)},
  // 'Corporate': {'icon': Icons.business, 'color': Color(0xfff50057)},
  'Default': {'icon': Icons.event, 'color': Colors.grey},
};

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _isLoading = true;
  bool _isScheduleLive = false;
  Map<String, dynamic> _scheduleData = {};
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  final Color neonCyan = const Color(0xFF00FFFF);

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await _remoteConfig.setDefaults(const {
      "is_schedule_live": false,
      "fest_schedule_json": "{}",
    });
    await _fetchAndActivate();
  }

  Future<void> _fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _isScheduleLive = _remoteConfig.getBool('is_schedule_live');
      if (_isScheduleLive) {
        final scheduleJsonString =
            _remoteConfig.getString('fest_schedule_json');
        _scheduleData = json.decode(scheduleJsonString);
        _populateCategories();
      }
    } catch (e) {
      print("Error fetching remote config: $e");
      _isScheduleLive = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _populateCategories() {
    final Set<String> allCategories = {'All'};
    final List<dynamic> days = _scheduleData['days'] ?? [];
    for (var day in days) {
      final List<dynamic> events = day['events'] ?? [];
      for (var event in events) {
        if (event['category'] != null) {
          allCategories.add(event['category']);
        }
      }
    }
    _categories = allCategories.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(title: const Text("Loading Schedule...")),
        body: Stack(
          children: [
            const AnimatedGradientBackground(),
            Center(
              child: CircularProgressIndicator(),
            )
          ],
        ),
      );
    }

    if (!_isScheduleLive) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const AnimatedGradientBackground(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timelapse_outlined,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  const Text("Coming Soon",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const Text("The future is not yet written.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final List<dynamic> days = _scheduleData['days'] ?? [];
    return Stack(
      children: [
        const AnimatedGradientBackground(),
        DefaultTabController(
          length: days.length,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Events Timeline',
                        textStyle: GoogleFonts.orbitron(
                          color: neonCyan,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        speed: const Duration(milliseconds: 80),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Filter by Category',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      dropdownColor: const Color(0xFF16213e),
                      style: const TextStyle(color: Colors.white),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                            value: category, child: Text(category));
                      }).toList(),
                      onChanged: (newValue) =>
                          setState(() => _selectedCategory = newValue!),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: days.map((day) {
                        final List<dynamic> allEvents =
                            List.from(day['events'] ?? [])
                              ..sort((a, b) =>
                                  a['startTime'].compareTo(b['startTime']));
                        final List<dynamic> filteredEvents =
                            _selectedCategory == 'All'
                                ? allEvents
                                : allEvents
                                    .where((event) =>
                                        event['category'] == _selectedCategory)
                                    .toList();
                        if (filteredEvents.isEmpty)
                          return Center(
                              child: Text(
                                  'No events for this category on ${day['title']}.',
                                  style:
                                      const TextStyle(color: Colors.white70)));
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) => EventTimelineTile(
                            event: filteredEvents[index],
                            animation: AnimationController(
                              vsync: this,
                              duration: const Duration(milliseconds: 600),
                            )..forward(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventTimelineTile extends StatelessWidget {
  final Map<String, dynamic> event;
  final Animation<double> animation;
  const EventTimelineTile(
      {Key? key, required this.event, required this.animation})
      : super(key: key);

  String _formatTime(String time) {
    try {
      return DateFormat("h:mm a").format(DateFormat("HH:mm").parse(time));
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String category = event['category'] ?? 'Default';
    final IconData icon = categoryStyles[category]?['icon'] ?? Icons.event;
    final Color color = categoryStyles[category]?['color'] ?? Colors.grey;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final Color timelineColor =
        isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final Color cardColor =
        isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final Color iconBgColor = color.withOpacity(0.15);
    final Color iconFgColor = color;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(animation.value);
        final scale = 0.9 + 0.1 * t;
        final offset = Offset(0, (1 - t) * 30);

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: offset,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          final String venueName = event['venue'];
          // Replace direct MapScreen navigation with landing screen navigation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LandingScreen(initialTab: 0, initialVenue: venueName),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_formatTime(event['startTime']),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor)),
                    Text(_formatTime(event['endTime']),
                        style: TextStyle(color: subTextColor, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 30,
                child: Column(
                  children: [
                    Container(width: 2, height: 20, color: timelineColor),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        boxShadow: [
                          BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2)
                        ],
                      ),
                      child: Icon(icon, size: 16, color: Colors.black),
                    ),
                    Expanded(child: Container(width: 2, color: timelineColor)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24.0, top: 10.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: timelineColor),
                    boxShadow: [
                      BoxShadow(
                          color: color.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['name'],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16, color: subTextColor),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(event['venue'],
                                  style: TextStyle(
                                      fontSize: 14, color: subTextColor))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.5)),
                        ),
                        child: Text(category,
                            style: TextStyle(
                                fontSize: 12,
                                color: iconFgColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
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
