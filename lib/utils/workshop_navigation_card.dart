import 'package:techniche26/model/events_data.dart'; 
import 'package:techniche26/view/sub_category_screen.dart'; 
import 'package:flutter/material.dart';

class WorkshopNavigationCard extends StatelessWidget {
  final MainCategory workshopData;

  const WorkshopNavigationCard({
    super.key,
    required this.workshopData, 
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
        color: theme.colorScheme.surface
            .withOpacity(0.8), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        elevation: 0, 
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
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
