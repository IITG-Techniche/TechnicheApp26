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
  }) {
    final textPrimary = isDark ? Colors.white : const Color(0XFF232930);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985);

    return GestureDetector(
      onTap: () => onEventTap(title),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF002B5B),
                    child: const Center(
                      child: Icon(Icons.smart_toy_outlined,
                          size: 64, color: Colors.white38),
                    ),
                  ),
                ),
              ),
            ),
            // Dark overlay gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Sleek category tag badge at top left
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38BDF8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'FLAGSHIP EVENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontFamily: 'General Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Floating Info card at the bottom
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155).withOpacity(0.4)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
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
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                              fontFamily: 'General Sans',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
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
                    const SizedBox(width: 8),
                    // Bell button
                    GestureDetector(
                      onTap: () => onSetReminder(title),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE4F0FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 20,
                          color:
                              isDark ? Colors.white : const Color(0xFF0D256B),
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
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 2.0, bottom: 15.0),
          child: Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textSecondary,
              fontFamily: AppTheme.fontUnivers,
            ),
          ),
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 427,
            enlargeCenterPage: true,
            viewportFraction: 0.72,
            enlargeFactor: 0.2,
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
            ),
            _buildUpcomingEventCard(
              context,
              title: 'Aquawars',
              image: 'assets/robotics.jpeg',
              date: '21 Aug (Today) | 3:30 PM',
              venue: 'Olympic Swimming Pool Complex',
            ),
            _buildUpcomingEventCard(
              context,
              title: 'Escalade',
              image: 'assets/escalade.png',
              date: '21 Aug (Today) | 4:30 PM',
              venue: 'Amphitheatre, IIT Guwahati',
            ),
          ],
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
