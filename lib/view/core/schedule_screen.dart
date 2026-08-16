import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:techniche26/view/core/landing_screen.dart';
import 'package:techniche26/widgets/app_drawer.dart';

const Map<String, Map<String, dynamic>> categoryStyles = {
  'Robotics': {'icon': Icons.smart_toy_outlined, 'color': Color(0xFF7C3EC3)},
  'Hackathons': {'icon': Icons.code, 'color': Color(0xFF175BCC)},
  'Workshops': {'icon': Icons.build_outlined, 'color': Color(0xFFE56B1F)},
  'Techno': {'icon': Icons.lightbulb_outline, 'color': Color(0xFF23242B)},
  'Tech-Expo': {'icon': Icons.camera_alt_outlined, 'color': Color(0xFF008E6B)},
  'Lecture Series': {
    'icon': Icons.mic_external_on_outlined,
    'color': Color(0xFFD81B60)
  },
  'Entertainment': {
    'icon': Icons.music_note_outlined,
    'color': Color(0xFFF4511E)
  },
  'Nexus': {'icon': Icons.people_outline, 'color': Color(0xFF00796B)},
  'Funniche': {'icon': Icons.gamepad_outlined, 'color': Color(0xFF8E24AA)},
  'Default': {'icon': Icons.event, 'color': Color(0xFF607D8B)},
};

class SchedulePage extends StatefulWidget {
  static const String routeName = '/schedule';
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

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 100),
      minimumFetchInterval: const Duration(seconds: 600),
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
      debugPrint("Error fetching remote config: $e");
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
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF002B5B)),
        ),
      );
    }

    if (!_isScheduleLive) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        drawer: const AppDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 100),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timelapse_outlined,
                        size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 20),
                    const Text("Coming Soon",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Univers',
                            height: 1.07,
                            color: Color(0XFF232930))),
                    const SizedBox(height: 8),
                    const Text("The future is not yet written.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFF6D7985),
                            fontFamily: 'General Sans')),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }

    final List<dynamic> days = _scheduleData['days'] ?? [];
    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        drawer: const AppDrawer(),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Filter by Category',
                      labelStyle: const TextStyle(
                          color: Color(0xFF6D7985), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF002B5B), width: 1.5),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                        color: Color(0XFF232930), fontWeight: FontWeight.w600),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                          value: category, child: Text(category));
                    }).toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedCategory = newValue!),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  Container(
                    color: const Color(0xFFF5F5F5),
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: const Color(0xFF002B5B),
                      unselectedLabelColor: const Color(0xFF6D7985),
                      indicatorColor: const Color(0xFF002B5B),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontFamily: 'Univers'),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500, fontFamily: 'Univers'),
                      tabs: days.map((day) => Tab(text: day['title'])).toList(),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: days.map((day) {
              final List<dynamic> allEvents = List.from(day['events'] ?? [])
                ..sort((a, b) => a['startTime'].compareTo(b['startTime']));
              final List<dynamic> filteredEvents = _selectedCategory == 'All'
                  ? allEvents
                  : allEvents
                      .where((event) => event['category'] == _selectedCategory)
                      .toList();

              if (filteredEvents.isEmpty) {
                return Center(
                    child: Text(
                        'No events for this category on ${day['title']}.',
                        style: const TextStyle(color: Color(0xFF6D7985))));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF002B5B),
        image: DecorationImage(
          image: AssetImage('assets/ghm/frame3.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFAFAFAF),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Builder(
                    builder: (BuildContext innerContext) {
                      return GestureDetector(
                        onTap: () {
                          Scaffold.of(innerContext).openDrawer();
                        },
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset(
                            'assets/ghm/menu.png',
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 24.0,
                    child: Image.asset(
                      'assets/ghm/logo3.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    const Color textColor = Color(0XFF232930);
    const Color subTextColor = Color(0xFF6D7985);
    final Color timelineColor = Colors.grey.shade300;
    const Color cardColor = Color(0xFFF8F9FA);
    final Color iconBgColor = color.withOpacity(0.1);
    final Color iconFgColor = color;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(animation.value);
        final scale = 0.95 + 0.05 * t;
        final offset = Offset(0, (1 - t) * 20);

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
                width: 75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_formatTime(event['startTime']),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'General Sans',
                            height: 1.2,
                            color: textColor,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(_formatTime(event['endTime']),
                        style:
                            const TextStyle(color: subTextColor, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(width: 2, height: 20, color: timelineColor),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Icon(icon, size: 12, color: color),
                    ),
                    Expanded(child: Container(width: 2, color: timelineColor)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20.0, top: 4.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['name'],
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Univers',
                              height: 1.2,
                              color: textColor)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: subTextColor),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(event['venue'],
                                  style: const TextStyle(
                                      fontSize: 13, color: subTextColor))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(category,
                            style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'General Sans',
                                color: iconFgColor,
                                fontWeight: FontWeight.w700)),
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
