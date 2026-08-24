import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:techniche26/constant/appTheme.dart';
import 'package:techniche26/services/home_featured_events_service.dart';

class HomeUpcomingEventsSection extends StatelessWidget {
  final bool isDark;
  final Function(String title) onEventTap;
  final Function(String title) onSetReminder;

  const HomeUpcomingEventsSection({
    super.key,
    required this.isDark,
    required this.onEventTap,
    required this.onSetReminder,
  });

  Widget _buildPosterImage({
    required String imageUrl,
    required String fallbackAsset,
    required double cardWidth,
    required double cardHeight,
    required double widthRatio,
  }) {
    if (imageUrl.isNotEmpty && (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      return Image.network(
        imageUrl,
        width: cardWidth,
        height: cardHeight,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildAssetOrFallback(fallbackAsset, cardWidth, cardHeight),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF3B82F6),
              ),
            ),
          );
        },
      );
    }
    return _buildAssetOrFallback(fallbackAsset, cardWidth, cardHeight);
  }

  Widget _buildAssetOrFallback(String assetPath, double width, double height) {
    final path = assetPath.isNotEmpty ? assetPath : 'assets/robo.png';
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF0F172A),
        child: const Center(
          child: Icon(
            Icons.smart_toy_outlined,
            size: 64,
            color: Colors.white38,
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEventCard(
    BuildContext context, {
    required String title,
    required String imageUrl,
    required String fallbackAsset,
    required String date,
    required String venue,
    required String? tag,
    required double cardWidth,
    required double cardHeight,
    required double boxWidth,
    required double boxHeight,
    required double widthRatio,
  }) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () => onEventTap(title),
      child: Center(
        child: SizedBox(
          width: cardWidth,
          height: cardHeight + (boxHeight / 2),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // 1. Poster Image (270 x 361 ratio)
              Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20 * widthRatio),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.black.withOpacity(0.12),
                      blurRadius: 14 * widthRatio,
                      offset: Offset(0, 6 * widthRatio),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20 * widthRatio),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _buildPosterImage(
                          imageUrl: imageUrl,
                          fallbackAsset: fallbackAsset,
                          cardWidth: cardWidth,
                          cardHeight: cardHeight,
                          widthRatio: widthRatio,
                        ),
                      ),
                      if (tag != null && tag.isNotEmpty)
                        Positioned(
                          top: 14 * widthRatio,
                          left: 14 * widthRatio,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10 * widthRatio,
                              vertical: 5 * widthRatio,
                            ),
                            decoration: BoxDecoration(
                              color: tag.toUpperCase() == 'LIVE NOW'
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(20 * widthRatio),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (tag.toUpperCase() == 'LIVE NOW') ...[
                                  Container(
                                    width: 6 * widthRatio,
                                    height: 6 * widthRatio,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 5 * widthRatio),
                                ],
                                Text(
                                  tag.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10 * widthRatio,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
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

              // 2. Floating Bottom Info Card (238 x 98 ratio) - Half Inside Poster, Half Outside Below
              Positioned(
                bottom: 0,
                child: Container(
                  width: boxWidth,
                  height: boxHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 * widthRatio,
                    vertical: 10 * widthRatio,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(16 * widthRatio),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.6)
                            : Colors.black.withOpacity(0.10),
                        blurRadius: 14 * widthRatio,
                        offset: Offset(0, 6 * widthRatio),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12 * widthRatio,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2B53B4),
                                fontFamily: 'General Sans',
                              ),
                            ),
                            SizedBox(height: 2 * widthRatio),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16 * widthRatio,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                                fontFamily: 'General Sans',
                              ),
                            ),
                            SizedBox(height: 2 * widthRatio),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13 * widthRatio,
                                  color: textSecondary,
                                ),
                                SizedBox(width: 3 * widthRatio),
                                Expanded(
                                  child: Text(
                                    venue,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11 * widthRatio,
                                      color: textSecondary,
                                      fontFamily: 'General Sans',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 8 * widthRatio),

                      // Squircle Bell Reminder Button
                      GestureDetector(
                        onTap: () => onSetReminder(title),
                        child: Container(
                          width: 36 * widthRatio,
                          height: 36 * widthRatio,
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFDCEBFE),
                                      Color(0xFFEFF6FF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            color: isDark ? const Color(0xFF1E293B) : null,
                            borderRadius:
                                BorderRadius.circular(12 * widthRatio),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFBFDBFE),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 18 * widthRatio,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
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

  List<HomeFeaturedEventModel> _getFallbackEvents() {
    return [
      HomeFeaturedEventModel(
        id: 'robowars_2026',
        title: 'Robowars',
        category: 'Robotics',
        date: '28th August 2026',
        venue: 'IIT Guwahati Campus',
        imageUrl: '',
        fallbackAsset: 'assets/robo.png',
        order: 1,
        isActive: true,
        tag: 'LIVE NOW',
      ),
      HomeFeaturedEventModel(
        id: 'aquawars_2026',
        title: 'Aquawars',
        category: 'Robotics',
        date: '29th - 30th August 2026',
        venue: 'IIT Guwahati Campus',
        imageUrl: '',
        fallbackAsset: 'assets/robotics.jpeg',
        order: 2,
        isActive: true,
      ),
      HomeFeaturedEventModel(
        id: 'escalade_2026',
        title: 'Escalade',
        category: 'Competitions',
        date: '28th - 29th August 2026',
        venue: 'IIT Guwahati Campus',
        imageUrl: '',
        fallbackAsset: 'assets/escalade.png',
        order: 3,
        isActive: true,
      ),
      HomeFeaturedEventModel(
        id: 'track_titans_2026',
        title: 'Track Titans',
        category: 'Robotics',
        date: '29th August 2026',
        venue: 'IIT Guwahati Campus',
        imageUrl: '',
        fallbackAsset: 'assets/robotics.jpeg',
        order: 4,
        isActive: true,
      ),
      HomeFeaturedEventModel(
        id: 'linequest_2026',
        title: 'LineQuest',
        category: 'Robotics',
        date: '29th August 2026',
        venue: 'IIT Guwahati Campus',
        imageUrl: '',
        fallbackAsset: 'assets/micro.png',
        order: 5,
        isActive: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double widthRatio = (screenWidth / 390.0).clamp(0.85, 1.25);

    final double cardWidth = 270.0 * widthRatio;
    final double cardHeight = 361.0 * widthRatio;
    final double boxWidth = 238.0 * widthRatio;
    final double boxHeight = 98.0 * widthRatio;
    final double totalSliderHeight = cardHeight + (boxHeight / 2) + (16.0 * widthRatio);

    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985);

    return StreamBuilder<List<HomeFeaturedEventModel>>(
      stream: HomeFeaturedEventsService().getFeaturedEventsStream(),
      builder: (context, snapshot) {
        debugPrint("📊 StreamBuilder state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, hasError: ${snapshot.hasError}");
        if (snapshot.hasError) {
          debugPrint("❌ StreamBuilder Error: ${snapshot.error}");
        }
        
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.hasData ? snapshot.data! : _getFallbackEvents();
        debugPrint("🎯 Events to display count: ${events.length}");

        if (events.isEmpty) {
          debugPrint("⚠️ Events list is empty, hiding section.");
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 20.0 * widthRatio,
                top: 6.0,
                bottom: 12.0 * widthRatio,
              ),
              child: Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 22 * widthRatio,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                  fontFamily: AppTheme.fontUnivers,
                ),
              ),
            ),
            CarouselSlider(
              options: CarouselOptions(
                height: totalSliderHeight,
                enlargeCenterPage: true,
                viewportFraction: 0.71,
                enlargeFactor: 0.24,
                enableInfiniteScroll: events.length > 1,
                scrollPhysics: const BouncingScrollPhysics(),
              ),
              items: events.map((event) {
                return _buildUpcomingEventCard(
                  context,
                  title: event.title,
                  imageUrl: event.imageUrl,
                  fallbackAsset: event.fallbackAsset,
                  date: event.date,
                  venue: event.venue,
                  tag: event.tag,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                  boxWidth: boxWidth,
                  boxHeight: boxHeight,
                  widthRatio: widthRatio,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

