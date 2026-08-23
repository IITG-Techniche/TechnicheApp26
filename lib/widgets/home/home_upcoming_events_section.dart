import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:techniche26/constant/appTheme.dart';

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

  Widget _buildUpcomingEventCard(
    BuildContext context, {
    required String title,
    required String image,
    required String date,
    required String venue,
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
                  child: Image.asset(
                    image,
                    width: cardWidth,
                    height: cardHeight,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double widthRatio = (screenWidth / 390.0).clamp(0.85, 1.25);

    // Exact Figma specifications:
    // Center card poster: 270 x 361
    // Floating info box: 238 x 98 (half overlapping bottom)
    // Inactive side cards scaled to: 205 x 274 (factor = 205/270 = 0.76 => enlargeFactor = 0.24)
    final double cardWidth = 270.0 * widthRatio;
    final double cardHeight = 361.0 * widthRatio;
    final double boxWidth = 238.0 * widthRatio;
    final double boxHeight = 98.0 * widthRatio;
    final double totalSliderHeight = cardHeight + (boxHeight / 2) + (16.0 * widthRatio);

    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985);

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
            enlargeFactor: 0.24, // Scales side cards to exact 205 x 274!
            enableInfiniteScroll: true,
            scrollPhysics: const BouncingScrollPhysics(),
          ),
          items: [
            _buildUpcomingEventCard(
              context,
              title: 'Robowars',
              image: 'assets/robo.png',
              date: '28th August 2026',
              venue: 'IIT Guwahati Campus',
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              boxWidth: boxWidth,
              boxHeight: boxHeight,
              widthRatio: widthRatio,
            ),
            _buildUpcomingEventCard(
              context,
              title: 'Aquawars',
              image: 'assets/robotics.jpeg',
              date: '29th - 30th August 2026',
              venue: 'IIT Guwahati Campus',
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              boxWidth: boxWidth,
              boxHeight: boxHeight,
              widthRatio: widthRatio,
            ),
            _buildUpcomingEventCard(
              context,
              title: 'Escalade',
              image: 'assets/escalade.png',
              date: '28th - 29th August 2026',
              venue: 'IIT Guwahati Campus',
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              boxWidth: boxWidth,
              boxHeight: boxHeight,
              widthRatio: widthRatio,
            ),
            _buildUpcomingEventCard(
              context,
              title: 'Track Titans',
              image: 'assets/robotics.jpeg',
              date: '29th August 2026',
              venue: 'IIT Guwahati Campus',
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              boxWidth: boxWidth,
              boxHeight: boxHeight,
              widthRatio: widthRatio,
            ),
            _buildUpcomingEventCard(
              context,
              title: 'LineQuest',
              image: 'assets/micro.png',
              date: '29th August 2026',
              venue: 'IIT Guwahati Campus',
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              boxWidth: boxWidth,
              boxHeight: boxHeight,
              widthRatio: widthRatio,
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
