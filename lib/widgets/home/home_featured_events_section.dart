import 'package:flutter/material.dart';
import 'package:techniche26/constant/appTheme.dart';
import 'package:techniche26/model/events_data.dart';

class HomeFeaturedEventsSection extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> featuredEvents;
  final Function(String title) onEventTap;

  const HomeFeaturedEventsSection({
    super.key,
    required this.isDark,
    required this.featuredEvents,
    required this.onEventTap,
  });

  Widget _buildFeaturedEventTile(
    BuildContext context, {
    required String title,
    required String desc,
    required String category,
  }) {
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0XFF232930);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985);

    final eventDetail = findEventByTitle(title);
    final imageAsset = eventDetail?.imageAsset ??
        (title.toLowerCase().contains('escalade')
            ? 'assets/escalade.png'
            : (title.toLowerCase().contains('aqua')
                ? 'assets/robotics.jpeg'
                : 'assets/robo.png'));

    final rawDesc = desc.isNotEmpty ? desc : (eventDetail?.description ?? '');
    final cleanDesc = (rawDesc.contains('somtehdhkjjbsd') || rawDesc.trim().isEmpty)
        ? (eventDetail?.description ??
            'Experience state-of-the-art technological competitions at Techniche 2026.')
        : rawDesc;

    final displayCategory =
        (eventDetail?.category != null && eventDetail!.category!.isNotEmpty)
            ? eventDetail.category!
            : category;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155).withOpacity(0.4)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onEventTap(title),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Event image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    imageAsset,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.smart_toy_outlined,
                        color: isDark ? Colors.white54 : const Color(0xFF175BCC),
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E294A)
                              : const Color(0xFFE4F0FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          displayCategory,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF175BCC),
                            fontFamily: 'General Sans',
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                          fontFamily: 'General Sans',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cleanDesc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                          fontFamily: 'General Sans',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textSecondary,
              fontFamily: AppTheme.fontUnivers,
            ),
          ),
          const SizedBox(height: 15),
          ...featuredEvents.map(
            (event) => _buildFeaturedEventTile(
              context,
              title: event['name'] ?? event['title'] ?? '',
              desc: event['venue'] ?? event['desc'] ?? '',
              category: event['category'] ?? 'Event',
            ),
          ),
        ],
      ),
    );
  }
}
