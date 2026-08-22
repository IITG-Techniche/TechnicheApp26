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
    required double cardHeight,
  }) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () => onEventTap(title),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Stack(
          children: [
            // 1. Full-bleed Event Poster Image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  image,
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

            // 2. Subtle Dark Gradient Overlay at Bottom
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.55),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Floating Bottom Info Card
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black54
                          : Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text Column: Date, Title, Venue
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2B53B4),
                              fontFamily: 'General Sans',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                              fontFamily: 'General Sans',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  venue,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
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

                    const SizedBox(width: 10),

                    // Squircle Bell Reminder Button (Matching Figma Design)
                    GestureDetector(
                      onTap: () => onSetReminder(title),
                      child: Container(
                        width: 38,
                        height: 38,
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFBFDBFE),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 19,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double widthRatio = (screenWidth / 390.0).clamp(0.85, 1.25);
    final double cardHeight = (400.0 * widthRatio).clamp(360.0, 440.0);

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
            height: cardHeight,
            enlargeCenterPage: true,
            viewportFraction: 0.74,
            enlargeFactor: 0.18,
            enableInfiniteScroll: true,
            scrollPhysics: const BouncingScrollPhysics(),
          ),
          items: [
            _buildUpcomingEventCard(
              context,
              title: 'Robowars',
              image: 'assets/robo.png',
              date: '21 Aug (Today) | 2:30 PM',
              venue: 'L1 - Lecture Hall, IIT Guwahati',
              cardHeight: cardHeight,
            ),
            _buildUpcomingEventCard(
              context,
              title: 'Aquawars',
              image: 'assets/robotics.jpeg',
              date: '21 Aug (Today) | 3:30 PM',
              venue: 'Olympic Swimming Pool Complex',
              cardHeight: cardHeight,
            ),
            _buildUpcomingEventCard(
              context,
              title: 'Escalade',
              image: 'assets/escalade.png',
              date: '21 Aug (Today) | 4:30 PM',
              venue: 'Amphitheatre, IIT Guwahati',
              cardHeight: cardHeight,
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
