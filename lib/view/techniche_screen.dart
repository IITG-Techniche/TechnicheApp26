import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../model/events_data.dart';
import 'event_detail_sheet.dart';
import '../constant/appTheme.dart';

class EventsScreen extends StatefulWidget {
  static const String routeName = '/events-screen';
  final bool isTab;

  const EventsScreen({super.key, this.isTab = false});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: eventData.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                Container(
                  color: AppTheme.backgroundGray,
                  child: Column(
                    children: [
                      _buildTabBar(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: eventData.map((category) {
            return _buildSubCategoryGrid(category.subCategories);
          }).toList(),
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
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
      height: 45,
      margin: const EdgeInsets.only(top: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(width: 3, color: Color(0xFF002B5B)),
          borderRadius: BorderRadius.circular(3),
        ),
        dividerColor: const Color(0xFFE8E8E8),
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
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 400),
            columnCount: 2,
            child: SlideAnimation(
              verticalOffset: 30.0,
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subCategory.title,
                    style: const TextStyle(
                      fontSize: 14,
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
      color = const Color(0xFFBDBDBD);
      bgColor = const Color(0xFFF5F5F5);
    } else {
      text = events.length == 1 && events.first.redirectUrl != null
          ? 'REGISTER NOW'
          : '${events.length} EVENTS';
      color = const Color(0xFF002B5B);
      bgColor = const Color(0xFFE1EBFF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: AppTheme.fontGeneralSans,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => 69.0;
  @override
  double get maxExtent => 69.0;

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
