import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:techniche26/constant/appTheme.dart';
import 'package:techniche26/view/core/landing_screen.dart';

const Map<String, Map<String, dynamic>> categoryStyles = {
  'Robotics': {'icon': Icons.smart_toy_outlined, 'color': Color(0xFF7C3EC3)},
  'Hackathons': {'icon': Icons.code, 'color': Color(0xFF175BCC)},
  'Workshops': {'icon': Icons.build_outlined, 'color': Color(0xFFE56B1F)},
  'Techno': {'icon': Icons.lightbulb_outline, 'color': Color(0xFF0284C7)},
  'Tech-Expo': {'icon': Icons.camera_alt_outlined, 'color': Color(0xFF059669)},
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
  'Default': {'icon': Icons.event, 'color': Color(0xFF64748B)},
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
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 60),
      ));
      await _remoteConfig.setDefaults(const {
        "is_schedule_live": false,
        "fest_schedule_json": "{}",
      });
      await _fetchAndActivate();
    } catch (e) {
      debugPrint("Error initializing remote config: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _isScheduleLive = _remoteConfig.getBool('is_schedule_live');
      if (_isScheduleLive) {
        final scheduleJsonString =
            _remoteConfig.getString('fest_schedule_json');
        if (scheduleJsonString.isNotEmpty && scheduleJsonString != '{}') {
          _scheduleData = json.decode(scheduleJsonString);
          _populateCategories();
        }
      }
    } catch (e) {
      debugPrint("Error fetching remote config for schedule: $e");
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkPageBg : AppTheme.lightPageBg;
    final textPrimary =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    if (!_isScheduleLive || (_scheduleData['days'] as List?)?.isEmpty == true) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, textPrimary),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryBlue.withOpacity(0.12),
                          ),
                          child: const Icon(
                            Icons.edit_calendar_rounded,
                            size: 64,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'SCHEDULE COMING SOON',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTheme.fontUnivers,
                            letterSpacing: 0.5,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'The official Techniche 26 fest timeline is currently being finalized. Check back soon for live updates!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontFamily: AppTheme.fontGeneralSans,
                            color: textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<dynamic> days = _scheduleData['days'] ?? [];
    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: _buildHeader(context, textPrimary),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: _buildCategoryDropdown(isDark, textPrimary, textSecondary),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    Container(
                      color: bgColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: AppTheme.primaryBlue,
                        unselectedLabelColor: textSecondary,
                        indicatorColor: AppTheme.primaryBlue,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: AppTheme.fontUnivers,
                          fontSize: 14,
                        ),
                        tabs: days
                            .map((day) => Tab(text: day['title'] ?? 'Day'))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: days.map((day) {
                final List<dynamic> allEvents = List.from(day['events'] ?? [])
                  ..sort((a, b) =>
                      (a['startTime'] ?? '').compareTo(b['startTime'] ?? ''));
                final List<dynamic> filteredEvents = _selectedCategory == 'All'
                    ? allEvents
                    : allEvents
                        .where(
                            (event) => event['category'] == _selectedCategory)
                        .toList();

                if (filteredEvents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No events scheduled for $_selectedCategory on ${day['title']}.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textSecondary,
                          fontFamily: AppTheme.fontGeneralSans,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) => EventTimelineTile(
                    event: filteredEvents[index],
                    isDark: isDark,
                    animation: AnimationController(
                      vsync: this,
                      duration: const Duration(milliseconds: 500),
                    )..forward(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // APP HEADER
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Schedule',
              style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontUnivers,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
              ),
            ),
            child: const Text(
              'TECHNICHE 26',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontUnivers,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORY DROPDOWN FILTER
  // ─────────────────────────────────────────────────────────────
  Widget _buildCategoryDropdown(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final cardBg = isDark ? AppTheme.darkCardsBg : AppTheme.lightCardsBg;
    final cardBorder =
        isDark ? const Color(0xFF282846) : const Color(0xFFE2E8F0);

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Filter by Category',
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 13,
          fontFamily: AppTheme.fontGeneralSans,
        ),
        filled: true,
        fillColor: cardBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
      ),
      dropdownColor: cardBg,
      style: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontFamily: AppTheme.fontGeneralSans,
        fontSize: 14,
      ),
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() => _selectedCategory = newValue);
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TIMELINE TILE ITEM WIDGET
// ─────────────────────────────────────────────────────────────
class EventTimelineTile extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isDark;
  final Animation<double> animation;

  const EventTimelineTile({
    Key? key,
    required this.event,
    required this.isDark,
    required this.animation,
  }) : super(key: key);

  String _formatTime(String time) {
    if (time.isEmpty) return '';
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
    final Color color =
        categoryStyles[category]?['color'] ?? AppTheme.primaryBlue;

    final cardBg = isDark ? AppTheme.darkCardsBg : AppTheme.lightCardsBg;
    final cardBorder =
        isDark ? const Color(0xFF282846) : const Color(0xFFE2E8F0);
    final textPrimary =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final timelineColor =
        isDark ? const Color(0xFF334155) : Colors.grey.shade300;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(animation.value);
        final scale = 0.96 + 0.04 * t;
        final offset = Offset(0, (1 - t) * 16);

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
          final String venueName = event['venue'] ?? '';
          if (venueName.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LandingScreen(initialTab: 3, initialVenue: venueName),
              ),
            );
          }
        },
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Time Label Column
              SizedBox(
                width: 75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(event['startTime'] ?? ''),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTheme.fontUnivers,
                        height: 1.2,
                        color: textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(event['endTime'] ?? ''),
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontFamily: AppTheme.fontGeneralSans,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Vertical Timeline Graphic Line & Dot
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(width: 2, height: 18, color: timelineColor),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppTheme.darkCardsBg : Colors.white,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Icon(icon, size: 12, color: color),
                    ),
                    Expanded(child: Container(width: 2, color: timelineColor)),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Event Detail Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16.0, top: 2.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['name'] ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                          height: 1.2,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event['venue'] ?? '',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontFamily: AppTheme.fontGeneralSans,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontFamily: AppTheme.fontUnivers,
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
