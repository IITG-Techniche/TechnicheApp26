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

          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blueAccent.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 24,
                    color:
                        isSelected ? const Color(0xFF00FFF7) : Colors.grey[400],
                  ),
                  if (isSelected) const SizedBox(width: 8),
                  if (isSelected)
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: Color(0xFF00FFF7),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
