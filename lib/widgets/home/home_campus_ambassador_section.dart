import 'package:flutter/material.dart';

class HomeCampusAmbassadorSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onJoinTap;

  const HomeCampusAmbassadorSection({
    super.key,
    required this.isDark,
    required this.onJoinTap,
  });

  Widget _buildOverlapAvatar(BuildContext context, String asset) {
    return Align(
      widthFactor: 0.6,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundImage: AssetImage(asset),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0XFF232930);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF6D7985);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E294A), const Color(0xFF0F162A)]
                : [const Color(0xFFD4E6FC), const Color(0xFFEEF5FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campus Ambassador\nProgram',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                height: 1.2,
                fontFamily: 'General Sans',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Represent Techniche at your campus & win exciting rewards',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                fontFamily: 'General Sans',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Container wrapping avatars & joined count
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOverlapAvatar(context, 'assets/arya-app.jpg'),
                      _buildOverlapAvatar(context, 'assets/ayush-app.jpg'),
                      _buildOverlapAvatar(context, 'assets/dhruv-app.jpg'),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4F0FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '+37 Joined',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF175BCC),
                            fontFamily: 'General Sans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Join Now button
                ElevatedButton(
                  onPressed: onJoinTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3D96),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Join Now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'General Sans',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
