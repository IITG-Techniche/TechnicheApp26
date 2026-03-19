import 'package:flutter/material.dart';

class GlowingBottomNavBarItem {
  final IconData icon;
  final String label;

  GlowingBottomNavBarItem({required this.icon, required this.label});
}

class GlowingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlowingBottomNavBarItem> items;

  const GlowingBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kBottomNavigationBarHeight + 15,
      //margin: const EdgeInsets.only(bottom: 16), // Push navbar up from bottom
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        boxShadow: [

        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          // Make selected item larger, unselected smaller
          final double iconSize = isSelected ? 22 : 22;
          final double fontSize = isSelected ? 10: 10;
          final double verticalPadding = isSelected ? 6 : 6;
          final double horizontalPadding = isSelected ? 6 : 8;

          return Expanded(
            flex: isSelected ? 1 : 1,
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: horizontalPadding,
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: iconSize,
                      color: isSelected
                          ? const Color(0xFF000000)
                          : Color(0XFF5E5E5E),
                    ),

                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF000000)
                              : Color(0XFF5E5E5E),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          fontFamily: 'General Sans',
                          height: 1.33,
                        ),
                      ),
                    ],

                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
