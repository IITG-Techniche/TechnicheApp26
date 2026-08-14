import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/events_data.dart';
import '../constant/appTheme.dart';
import 'eventdetailpage.dart';

class EventsScreen extends StatefulWidget {
  static const String routeName = '/events';
  final bool isTab;

  const EventsScreen({
    super.key,
    this.isTab = false,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: eventData.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          const Divider(height: 1, color: Color(0xFFE8E8E8)),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: eventData.map((category) {
                return _buildSubCategoryGrid(category.subCategories);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF002B5B),
        image: DecorationImage(
          image: AssetImage('assets/ghm/frame3.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFAFAFAF)),
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
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.isTab) {
                        Scaffold.of(context).openDrawer();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isTab
                            ? Icons.menu_rounded
                            : Icons.arrow_back_rounded,
                        color: const Color(0xFF6D7985),
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                  const Text(
                    'EVENTS',
                    style: TextStyle(
                      color: AppTheme.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontUnivers,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 3, color: Color(0xFF002B5B)),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: const Color(0xFF002B5B),
        unselectedLabelColor: const Color(0xFF6D7985),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          fontFamily: AppTheme.fontUnivers,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          fontFamily: AppTheme.fontGeneralSans,
        ),
        tabs: eventData.map((category) {
          return Tab(text: category.title.toUpperCase());
        }).toList(),
      ),
    );
  }

  Widget _buildSubCategoryGrid(List<SubCategory> subCategories) {
    if (subCategories.isEmpty) {
      return const Center(
        child: Text(
          'No events in this category yet',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontFamily: AppTheme.fontGeneralSans,
          ),
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 350),
            columnCount: 2,
            child: SlideAnimation(
              verticalOffset: 20.0,
              child: FadeInAnimation(
                child: _EventCard(
                  subCategory: subCategories[index],
                  onTap: () => showEventDetail(context, subCategories[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final SubCategory subCategory;
  final VoidCallback onTap;

  const _EventCard({
    required this.subCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'subcategory_${subCategory.title}',
                child: Image.asset(
                  subCategory.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE1EBFF),
                      child: const Center(
                        child: Icon(
                          Icons.category_rounded,
                          color: Color(0xFF002B5B),
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subCategory.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontUnivers,
                      color: AppTheme.textMain,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildEventBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBadge() {
    final events = subCategory.events;

    String text;
    Color color;
    Color bgColor;

    if (events.isEmpty) {
      text = 'Coming Soon';
      color = const Color(0xFF8E8E93);
      bgColor = const Color(0xFFF2F2F7);
    } else {
      text = events.length == 1 && events.first.redirectUrl != null
          ? 'REGISTER NOW'
          : '${events.length} EVENTS';
      color = const Color(0xFF002B5B);
      bgColor = const Color(0xFFE1EBFF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: AppTheme.fontGeneralSans,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Shows the appropriate event detail bottom sheet based on event data
void showEventDetail(BuildContext context, SubCategory subCategory) {
  if (subCategory.events.isEmpty) {
    _showComingSoonSheet(context, subCategory);
  } else if (subCategory.events.length == 1 &&
      subCategory.events.first.redirectUrl != null) {
    _showRedirectSheet(context, subCategory);
  } else {
    _showEventsListSheet(context, subCategory);
  }
}

void _showEventsListSheet(BuildContext context, SubCategory subCategory) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EventsListSheet(subCategory: subCategory),
  );
}

void _showRedirectSheet(BuildContext context, SubCategory subCategory) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RedirectSheet(subCategory: subCategory),
  );
}

void _showComingSoonSheet(BuildContext context, SubCategory subCategory) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ComingSoonSheet(subCategory: subCategory),
  );
}

class _EventsListSheet extends StatelessWidget {
  final SubCategory subCategory;

  const _EventsListSheet({
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Category Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        subCategory.imageAsset,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          width: 50,
                          height: 50,
                          color: const Color(0xFFE1EBFF),
                          child: const Icon(Icons.category_rounded,
                              color: Color(0xFF002B5B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        subCategory.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                          color: AppTheme.textMain,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0xFFE8E8E8)),

              // Events List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: subCategory.events.length,
                  itemBuilder: (context, index) {
                    final event = subCategory.events[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE8E8E8),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE1EBFF),
                          radius: 18,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppTheme.fontGeneralSans,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppTheme.fontGeneralSans,
                            color: AppTheme.textMain,
                            height: 1.2,
                          ),
                        ),
                        subtitle: event.subtitle != null
                            ? Text(
                                event.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontFamily: AppTheme.fontGeneralSans,
                                ),
                              )
                            : null,
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF6D7985),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailPage(
                                eventTitle: event.title,
                                event: event,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RedirectSheet extends StatelessWidget {
  final SubCategory subCategory;

  const _RedirectSheet({
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    final event = subCategory.events.first;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(
        bottom: 40,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              subCategory.imageAsset,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                color: const Color(0xFFE1EBFF),
                child: const Icon(Icons.category_rounded, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subCategory.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontUnivers,
                color: AppTheme.textMain,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002B5B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (event.redirectUrl != null) {
                    _launchUrl(context, event.redirectUrl!);
                  } else {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(
                          eventTitle: event.title,
                          event: event,
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'REGISTER ON UNSTOP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTheme.fontGeneralSans,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.launch_rounded,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonSheet extends StatelessWidget {
  final SubCategory subCategory;

  const _ComingSoonSheet({
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(
        bottom: 60,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              subCategory.imageAsset,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: const Color(0xFFE1EBFF),
                child: const Icon(Icons.category_rounded, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            subCategory.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.fontUnivers,
              color: AppTheme.textMain,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
              ),
            ),
            child: const Text(
              'COMING SOON',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontGeneralSans,
                color: AppTheme.textSecondary,
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchUrl(BuildContext context, String urlString) async {
  final url = Uri.parse(urlString);

  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot open link'),
        ),
      );
    }
  }
}