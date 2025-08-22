import 'package:amazon_clone/model/events_data.dart'; // Adjust this import path to your events_data.dart file
import 'package:amazon_clone/view/sub_category_screen.dart'; // Adjust this import path to your screen
import 'package:flutter/material.dart';

class WorkshopNavigationCard extends StatelessWidget {
  // The workshop data is now passed into the widget.
  final MainCategory workshopData;

  const WorkshopNavigationCard({
    super.key,
    required this.workshopData, // Added workshopData to the constructor.
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Card(
        color: theme.colorScheme.surface.withOpacity(0.8), // Use surface color from your theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        elevation: 0, // Elevation is handled by the container's box shadow
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Since SubCategoryScreen is not in your named router,
            // we push it directly using MaterialPageRoute.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubCategoryScreen(
                  categoryTitle: workshopData.title,
                  subCategories: workshopData.subCategories,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon with a neon glow effect
                Icon(
                  Icons.handyman_rounded,
                  size: 40,
                  color: theme.colorScheme.primary,
                  shadows: [
                    Shadow(
                      color: theme.colorScheme.primary,
                      blurRadius: 15.0,
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Column for title and subtitle, using your theme's text styles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workshopData.title,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Explore all hands-on workshops',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // A chevron icon to indicate it's tappable
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
