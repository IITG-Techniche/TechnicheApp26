import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:techniche26/constant/appTheme.dart';
import 'package:techniche26/view/core/landing_screen.dart';
import 'package:techniche26/features/event_reminders/domain/reminder_manager.dart';
import 'package:techniche26/features/event_reminders/presentation/reminder_picker_sheet.dart';

const Map<String, Color> categoryColors = {
  'Robotics': Color(0xFF8B5CF6),
  'Competitions': Color(0xFF3B82F6),
  'Hackathons': Color(0xFF10B981),
  'Workshops': Color(0xFFF59E0B),
  'Techno': Color(0xFF0284C7),
  'Tech-Expo': Color(0xFF14B8A6),
  'Lecture Series': Color(0xFFEC4899),
  'Entertainment': Color(0xFFF43F5E),
  'Nexus': Color(0xFF06B6D4),
  'Funniche': Color(0xFFA855F7),
  'Default': Color(0xFF64748B),
};

class SchedulePage extends StatefulWidget {
  static const String routeName = '/schedule';
  const SchedulePage({Key? key}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _isLoading = true;
  bool _isScheduleLive = false;
  Map<String, dynamic> _scheduleData = {};
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  String _searchQuery = '';
  bool _showSavedOnly = false;
  Set<String> _activeReminderIds = {};
  String? _expandedEventId;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
    _refreshReminders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshReminders() async {
    try {
      final reminders = await ReminderManager().getAllReminders();
      if (mounted) {
        setState(() {
          _activeReminderIds = reminders.map((r) => r.eventId).toSet();
        });
      }
    } catch (e) {
      debugPrint("Error fetching reminders: $e");
    }
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
    final bgColor = isDark ? const Color(0xFF070914) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF3B82F6),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (!_isScheduleLive || (_scheduleData['days'] as List?)?.isEmpty == true) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark, textPrimary),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFEFF6FF),
                            border: Border.all(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.schedule_rounded,
                              size: 32,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'SCHEDULE REVEALING SOON',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontFamily: AppTheme.fontUnivers,
                            letterSpacing: 1.2,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'The official Techniche fest schedule is being curated. Get ready for an epic multi-day experience!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppTheme.fontGeneralSans,
                            color: textSecondary,
                            height: 1.45,
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
                  child: _buildHeader(context, isDark, textPrimary),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSearchBar(isDark, textPrimary, textSecondary),
                        ),
                        const SizedBox(width: 10),
                        _buildBookmarkFilterToggle(isDark),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCategoryPills(isDark, textPrimary, textSecondary),
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
                        labelColor: const Color(0xFF3B82F6),
                        unselectedLabelColor: textSecondary,
                        indicatorColor: const Color(0xFF3B82F6),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 3,
                        dividerColor: Colors.transparent,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontFamily: AppTheme.fontUnivers,
                          fontSize: 14.5,
                          letterSpacing: 0.8,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                          fontSize: 14,
                        ),
                        tabs: days
                            .map((day) => Tab(text: (day['title'] ?? 'Day').toString().toUpperCase()))
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

                final List<dynamic> filteredEvents = allEvents.where((event) {
                  final eventId = ReminderManager().extractEventId(event);
                  final matchesSaved = !_showSavedOnly || _activeReminderIds.contains(eventId);
                  final matchesCategory = _selectedCategory == 'All' ||
                      event['category'] == _selectedCategory;
                  final matchesSearch = _searchQuery.isEmpty ||
                      (event['name'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      (event['venue'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                  return matchesSaved && matchesCategory && matchesSearch;
                }).toList();

                if (filteredEvents.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                            ),
                            child: Center(
                              child: Icon(
                                _showSavedOnly ? Icons.bookmark_outline_rounded : Icons.search_off_rounded,
                                size: 28,
                                color: textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showSavedOnly ? 'No saved events' : 'No events found',
                            style: TextStyle(
                              color: textPrimary,
                              fontFamily: AppTheme.fontUnivers,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _showSavedOnly
                                ? 'Tap the reminder bell on any event to save it to your personal schedule.'
                                : 'Try adjusting your search terms or category filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textSecondary,
                              fontFamily: AppTheme.fontGeneralSans,
                              fontSize: 13,
                            ),
                          ),
                          if (_showSavedOnly || _selectedCategory != 'All' || _searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showSavedOnly = false;
                                  _selectedCategory = 'All';
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF3B82F6),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppTheme.fontUnivers,
                                ),
                              ),
                              child: const Text('Reset All Filters'),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    final eventId = ReminderManager().extractEventId(event);
                    final isExpanded = _expandedEventId == eventId;
                    final hasReminder = _activeReminderIds.contains(eventId);

                    return EventTimelineTile(
                      event: event,
                      dayData: day,
                      isDark: isDark,
                      isFirst: index == 0,
                      isLast: index == filteredEvents.length - 1,
                      isExpanded: isExpanded,
                      hasReminder: hasReminder,
                      onTap: () {
                        setState(() {
                          _expandedEventId = isExpanded ? null : eventId;
                        });
                      },
                      onReminderTap: () async {
                        await ReminderPickerSheet.show(
                          context,
                          event: event,
                          onReminderUpdated: _refreshReminders,
                        );
                      },
                    );
                  },
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
  Widget _buildHeader(BuildContext context, bool isDark, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FEST SCHEDULE',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: AppTheme.fontUnivers,
                    letterSpacing: 1.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore sessions, competitions & shows',
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B),
                    fontSize: 12.5,
                    fontFamily: AppTheme.fontGeneralSans,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF3B82F6).withOpacity(0.4) : const Color(0xFF93C5FD),
              ),
            ),
            child: Text(
              'LIVE 2026',
              style: TextStyle(
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A),
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                fontFamily: AppTheme.fontUnivers,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SEARCH BAR
  // ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar(bool isDark, Color textPrimary, Color textSecondary) {
    final fillBg = isDark ? const Color(0xFF131728) : const Color(0xFFEDF2F7);
    final borderColor = isDark ? const Color(0xFF242A42) : const Color(0xFFE2E8F0);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: fillBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: TextStyle(
          color: textPrimary,
          fontSize: 13.5,
          fontFamily: AppTheme.fontGeneralSans,
        ),
        decoration: InputDecoration(
          hintText: 'Search events or venues...',
          hintStyle: TextStyle(
            color: textSecondary.withOpacity(0.7),
            fontSize: 13,
            fontFamily: AppTheme.fontGeneralSans,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: textSecondary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: textSecondary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SAVED SCHEDULE / BOOKMARK FILTER TOGGLE
  // ─────────────────────────────────────────────────────────────
  Widget _buildBookmarkFilterToggle(bool isDark) {
    final activeBg = const Color(0xFF3B82F6);
    final inactiveBg = isDark ? const Color(0xFF131728) : const Color(0xFFEDF2F7);
    final borderColor = isDark ? const Color(0xFF242A42) : const Color(0xFFE2E8F0);

    return InkWell(
      onTap: () => setState(() => _showSavedOnly = !_showSavedOnly),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: _showSavedOnly ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _showSavedOnly ? activeBg : borderColor,
          ),
        ),
        child: Center(
          child: Icon(
            _showSavedOnly ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            size: 20,
            color: _showSavedOnly
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CATEGORY PILLS FILTER
  // ─────────────────────────────────────────────────────────────
  Widget _buildCategoryPills(bool isDark, Color textPrimary, Color textSecondary) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          final Color catColor = categoryColors[category] ?? categoryColors['Default']!;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? catColor
                      : isDark
                          ? const Color(0xFF131728)
                          : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? catColor
                        : isDark
                            ? const Color(0xFF242A42)
                            : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (category != 'All') ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : catColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontFamily: AppTheme.fontUnivers,
                        color: isSelected
                            ? Colors.white
                            : isDark
                                ? Colors.white.withOpacity(0.9)
                                : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TIMELINE TILE ITEM WIDGET
// ─────────────────────────────────────────────────────────────
class EventTimelineTile extends StatelessWidget {
  final Map<String, dynamic> event;
  final dynamic dayData;
  final bool isDark;
  final bool isFirst;
  final bool isLast;
  final bool isExpanded;
  final bool hasReminder;
  final VoidCallback onTap;
  final VoidCallback onReminderTap;

  const EventTimelineTile({
    Key? key,
    required this.event,
    this.dayData,
    required this.isDark,
    this.isFirst = false,
    this.isLast = false,
    required this.isExpanded,
    required this.hasReminder,
    required this.onTap,
    required this.onReminderTap,
  }) : super(key: key);

  String _formatTime(String time) {
    if (time.isEmpty) return '';
    try {
      return DateFormat("h:mm a").format(DateFormat("HH:mm").parse(time));
    } catch (e) {
      return time;
    }
  }

  bool get _isLiveNow {
    try {
      final String startTimeStr = event['startTime'] ?? '';
      final String endTimeStr = event['endTime'] ?? '';
      if (startTimeStr.isEmpty || endTimeStr.isEmpty) return false;
      final now = DateTime.now();
      final startParts = startTimeStr.split(':');
      final endParts = endTimeStr.split(':');
      if (startParts.length < 2 || endParts.length < 2) return false;

      DateTime? eventDate;
      if (dayData != null && dayData['date'] != null) {
        eventDate = DateTime.tryParse(dayData['date']);
      }
      eventDate ??= now;

      final start = DateTime(
        eventDate.year, eventDate.month, eventDate.day,
        int.parse(startParts[0]), int.parse(startParts[1]),
      );
      final end = DateTime(
        eventDate.year, eventDate.month, eventDate.day,
        int.parse(endParts[0]), int.parse(endParts[1]),
      );

      return now.isAfter(start) && now.isBefore(end);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String category = event['category'] ?? 'Default';
    final Color catColor = categoryColors[category] ?? const Color(0xFF3B82F6);

    final cardBg = isDark ? const Color(0xFF131728) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF242A42) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final timelineColor = isDark ? const Color(0xFF242A42) : const Color(0xFFE2E8F0);

    final venueName = event['venue'] ?? 'IIT Guwahati Campus';
    final description = event['description'] ?? event['details'] ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time Column
            SizedBox(
              width: 68,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Text(
                    _formatTime(event['startTime'] ?? ''),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontFamily: AppTheme.fontUnivers,
                      height: 1.1,
                      color: textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatTime(event['endTime'] ?? ''),
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppTheme.fontGeneralSans,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Continuous Minimal Timeline Guide Line
            SizedBox(
              width: 16,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: isFirst ? 20 : 0,
                    bottom: isLast ? 20 : 0,
                    child: Container(
                      width: 2,
                      color: timelineColor,
                    ),
                  ),
                  Positioned(
                    top: 18,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isLiveNow ? const Color(0xFF10B981) : catColor,
                        border: Border.all(
                          color: isDark ? const Color(0xFF070914) : Colors.white,
                          width: 2,
                        ),
                        boxShadow: _isLiveNow
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Event Card
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isLiveNow
                        ? const Color(0xFF10B981)
                        : (isExpanded ? catColor : cardBorder),
                    width: (isExpanded || _isLiveNow) ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: catColor,
                          width: 4,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Top Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_isLiveNow) ...[
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.fiber_manual_record_rounded,
                                            size: 8,
                                            color: Color(0xFF10B981),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'LIVE NOW',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontFamily: AppTheme.fontUnivers,
                                              color: Color(0xFF10B981),
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  Text(
                                    event['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: AppTheme.fontUnivers,
                                      height: 1.25,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Saved Bell Button
                            InkWell(
                              onTap: onReminderTap,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  hasReminder
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_none_rounded,
                                  size: 20,
                                  color: hasReminder ? const Color(0xFF3B82F6) : textSecondary.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Subtitle Row (Category Pill & Venue)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: AppTheme.fontUnivers,
                                  color: catColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                venueName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: AppTheme.fontGeneralSans,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: textSecondary.withOpacity(0.6),
                            ),
                          ],
                        ),

                        // Expandable Tray Details
                        if (isExpanded) ...[
                          const SizedBox(height: 12),
                          Divider(
                            color: cardBorder,
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          if (description.toString().isNotEmpty) ...[
                            Text(
                              description.toString(),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontFamily: AppTheme.fontGeneralSans,
                                color: textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          Row(
                            children: [
                              // Set Reminder Action Pill
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: onReminderTap,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: hasReminder ? const Color(0xFF3B82F6) : cardBorder,
                                    ),
                                    backgroundColor: hasReminder
                                        ? const Color(0xFF3B82F6).withOpacity(0.1)
                                        : Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  child: Text(
                                    hasReminder ? 'Reminder Set' : 'Remind Me',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppTheme.fontUnivers,
                                      color: hasReminder ? const Color(0xFF3B82F6) : textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Locate Venue Map Action Pill
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (venueName.isNotEmpty) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LandingScreen(
                                            initialTab: 3,
                                            initialVenue: venueName,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFEFF6FF),
                                    foregroundColor: const Color(0xFF3B82F6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  child: const Text(
                                    'Locate Venue',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppTheme.fontUnivers,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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

