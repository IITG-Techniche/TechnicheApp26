import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/appTheme.dart';
import '../../model/team_data.dart';

class HeadsTeamScreen extends StatelessWidget {
  static const String routeName = '/heads-team';
  final List<HeadMember> heads;

  const HeadsTeamScreen({
    super.key,
    this.heads = kFestHeads,
  });

  Future<void> _launchLinkedIn(BuildContext context, String urlString) async {
    if (urlString.isEmpty) return;
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070B19) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('MEET THE HEADS'),
        backgroundColor: isDark ? const Color(0xFF070B19) : const Color(0xFFF8F9FA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: heads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final head = heads[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black45 : Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE1EBFF),
                    ),
                    child: ClipOval(
                      child: head.imageUrl.startsWith('http')
                          ? Image.network(
                              head.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 30,
                                color: Color(0xFF6D7985),
                              ),
                            )
                          : Image.asset(
                              head.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 30,
                                color: Color(0xFF6D7985),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Designation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          head.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTheme.fontUnivers,
                            color: isDark ? Colors.white : AppTheme.textMain,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          head.designation,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: AppTheme.fontGeneralSans,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // LinkedIn Button
                  if (head.linkedinUrl.isNotEmpty)
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A66C2).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.link_rounded,
                          size: 18,
                          color: Color(0xFF0A66C2),
                        ),
                      ),
                      onPressed: () => _launchLinkedIn(context, head.linkedinUrl),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
