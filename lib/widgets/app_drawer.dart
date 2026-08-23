import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techniche26/providers/navigation_provider.dart';
import 'package:techniche26/providers/theme_provider.dart';
import 'package:techniche26/view/auth/ca_auth_screen.dart';
import 'package:techniche26/view/events/events_screen.dart';

import 'package:techniche26/model/events_data.dart';
import 'package:techniche26/view/events/sub_category_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final backgroundColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final dividerColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE8E8E8);
    final textMain = isDark ? Colors.white : const Color(0XFF232930);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : Colors.black.withOpacity(0.4);

    return Drawer(
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSectionTitle('Fest Events', textSecondary),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.event_note_rounded,
                  title: 'Events',
                  routeName: EventsScreen.routeName,
                  isTab: true,
                  tabIndex: 0,
                  ref: ref,
                  textMain: textMain,
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.build_circle_rounded,
                  title: 'Workshops',
                  routeName: SubCategoryScreen.routeName,
                  textMain: textMain,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    final workshopCategory = eventData.firstWhere(
                      (cat) => cat.title.toLowerCase().contains('workshop'),
                      orElse: () => eventData.first,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubCategoryScreen(
                          categoryTitle: workshopCategory.title,
                          subCategories: workshopCategory.subCategories,
                        ),
                      ),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: dividerColor, height: 1),
                ),

                _buildSectionTitle('Campus & Preferences', textSecondary),

                // 1. Campus Ambassador
                _buildDrawerItem(
                  context: context,
                  icon: Icons.school_rounded,
                  title: 'Campus Ambassador',
                  routeName: CaAuthScreen.routeName,
                  textMain: textMain,
                  isDark: isDark,
                ),

                // 2. Bright/Dark Mode Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: ListTile(
                    leading: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B),
                      size: 22,
                    ),
                    title: Text(
                      isDark ? 'Dark Mode' : 'Bright Mode',
                      style: TextStyle(
                        color: textMain,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Univers',
                        height: 1.2,
                      ),
                    ),
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeColor: const Color(0xFF38BDF8),
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                              val ? ThemeMode.dark : ThemeMode.light,
                            );
                      },
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    dense: true,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(color: dividerColor, height: 1),
                ),

                _buildSectionTitle('More', textSecondary),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  title: 'My Profile',
                  routeName: '/profile',
                  textMain: textMain,
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.shopping_bag_rounded,
                  title: 'Merchandise',
                  routeName: '/merch',
                  textMain: textMain,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          _buildFooter(isDark),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(bool isDark) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090E25) : Colors.white,
      ),
      child: Stack(
        children: [
          // Background Image positioned to push the bottom wave cutout out of bounds
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            bottom: -120,
            child: Opacity(
              opacity: isDark ? 0.65 : 0.40,
              child: Image.asset(
                isDark ? 'assets/hero/hero.png' : 'assets/hero/heroLight.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 170,
                  child: Image.asset(
                    isDark ? 'assets/hero/heroLogo.png' : 'assets/hero/heroLogoLight.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enriching Minds, Inspiring Innovation',
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.8) : const Color(0xFF10152B).withOpacity(0.8),
                    fontSize: 12,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontFamily: 'General Sans',
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String routeName,
    required Color textMain,
    required bool isDark,
    bool isTab = false,
    int? tabIndex,
    WidgetRef? ref,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF002B5B),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textMain,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Univers',
            height: 1.2,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        dense: true,
        hoverColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F5F5),
        onTap: () {
          if (onTap != null) {
            onTap();
            return;
          }
          Navigator.pop(context); // Close the drawer
          if (isTab && tabIndex != null && ref != null) {
            ref.read(bottomNavSelectedIndexProvider.notifier).state = tabIndex;
            Navigator.popUntil(context, (route) {
              return route.settings.name == '/landing-screen' || route.isFirst;
            });
          } else {
            Navigator.pushNamed(context, routeName);
          }
        },
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8E8E8),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IIT Guwahati',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Univers',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© Techniche 2026',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : Colors.black.withOpacity(0.4),
              fontSize: 12,
              fontFamily: 'General Sans',
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
