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
        color: const Color(0xFF181A20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: -5,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          // Make selected item larger, unselected smaller
          final double iconSize = isSelected ? 30 : 22;
          final double fontSize = isSelected ? 12 : 10;
          final double verticalPadding = isSelected ? 10 : 6;
          final double horizontalPadding = isSelected ? 20 : 8;

          return Expanded(
            flex: isSelected ? 2 : 1,
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: horizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blueAccent.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: iconSize,
                      color: isSelected
                          ? const Color(0xFF00FFF7)
                          : Colors.grey[400],
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: const Color(0xFF00FFF7),
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    ],
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
