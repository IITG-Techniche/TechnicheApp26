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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: kBottomNavigationBarHeight + 15,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF070B19) : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8E8E8), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 22,
                      color: isSelected
                          ? (isDark ? Colors.white : const Color(0xFF002B5B))
                          : (isDark ? const Color(0xFF94A3B8).withOpacity(0.6) : const Color(0XFF6D7985).withOpacity(0.5)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? (isDark ? Colors.white : const Color(0xFF002B5B))
                            : (isDark ? const Color(0xFF94A3B8).withOpacity(0.6) : const Color(0XFF6D7985).withOpacity(0.5)),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 11,
                        fontFamily: 'General Sans',
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
