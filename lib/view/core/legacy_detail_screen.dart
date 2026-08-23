import 'package:flutter/material.dart';
import '../../constant/appTheme.dart';

class LegacyDetailScreen extends StatelessWidget {
  static const String routeName = '/legacy-detail';
  const LegacyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF070B19) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF0A0F24) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3B82F6).withOpacity(0.4) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : AppTheme.textMain;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE LEGACY',
                          style: TextStyle(
                            fontFamily: AppTheme.fontUnivers,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '27 Years of Enriching Minds, Inspiring Innovation',
                          style: TextStyle(
                            fontFamily: AppTheme.fontGeneralSans,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Overview Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? const Color(0xFF3B82F6).withOpacity(0.12)
                                    : Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About Techniche',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontUnivers,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Techniche is the annual Techno-Management festival of the Indian Institute of Technology Guwahati. Started in 1999 with a vision to foster a spirit of science, technology, and management among students across India, Techniche has grown into one of the largest techno-management festivals in South Asia.',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontGeneralSans,
                                  fontSize: 14,
                                  color: textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Stats Highlights
                        Row(
                          children: [
                            _buildStatCard('100K+', 'Footfall', isDark, cardColor, borderColor),
                            const SizedBox(width: 12),
                            _buildStatCard('500+', 'Colleges', isDark, cardColor, borderColor),
                            const SizedBox(width: 12),
                            _buildStatCard('27th', 'Edition', isDark, cardColor, borderColor),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Flagship Initiatives Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flagship Initiatives',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontUnivers,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildInitiativeRow('Technothlon', 'International School Championship across 500+ cities in India.', isDark),
                              const Divider(height: 20),
                              _buildInitiativeRow('Guwahati Half Marathon', 'Northeast India\'s biggest socio-athletic movement.', isDark),
                              const Divider(height: 20),
                              _buildInitiativeRow('Industrial Conclave', 'Bridging students, industry leaders, and innovators.', isDark),
                              const Divider(height: 20),
                              _buildInitiativeRow('Nexus & Workshops', 'Hands-on training, robowars, AI, and futuristic competitions.', isDark),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Top Corner Back Button
            Positioned(
              top: 10,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, bool isDark, Color cardColor, Color borderColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: AppTheme.fontUnivers,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontGeneralSans,
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitiativeRow(String title, String desc, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTheme.fontUnivers,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          desc,
          style: TextStyle(
            fontFamily: AppTheme.fontGeneralSans,
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
