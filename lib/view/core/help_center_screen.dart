import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/appTheme.dart';
import '../../model/help_center_data.dart';

class HelpCenterScreen extends StatefulWidget {
  static const String routeName = '/help-center';

  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final Set<int> _expandedFaqIndices = {};

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not dial $phoneNumber'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchExternalUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF175BCC),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Responsive theme tokens matching design specs
    final bgColor = isDark ? const Color(0xFF070B19) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF1E294A) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final pillBg =
        isDark ? const Color(0xFF1E294B) : const Color(0xFFDCE8F8);
    final pillText =
        isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF);
    final highlightBlue = const Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation App Bar ──
            _buildAppBar(context, textPrimary: textPrimary, isDark: isDark),

            // ── Main Scrollable Body ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Hospital Section ──
                    _buildHospitalCard(
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      pillBg: pillBg,
                      pillText: pillText,
                      highlightBlue: highlightBlue,
                    ),

                    const SizedBox(height: 18),

                    // ── 2. Accommodation Section ──
                    _buildAccommodationCard(
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      pillBg: pillBg,
                      pillText: pillText,
                      highlightBlue: highlightBlue,
                    ),

                    const SizedBox(height: 18),

                    // ── 3. Transport Section ──
                    _buildTransportCard(
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      pillBg: pillBg,
                      pillText: pillText,
                      highlightBlue: highlightBlue,
                    ),

                    const SizedBox(height: 24),

                    // ── 4. FAQs Section ──
                    _buildFaqsSection(
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 24),

                    // ── 5. Socials Section ──
                    _buildSocialsSection(
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────────────
  Widget _buildAppBar(
    BuildContext context, {
    required Color textPrimary,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 6),
          Text(
            'Help Center',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.fontUnivers,
              color: textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. HOSPITAL CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildHospitalCard({
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color pillBg,
    required Color pillText,
    required Color highlightBlue,
  }) {
    final contacts = HelpCenterData.hospitalContacts;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag Pill
          _buildPillTag(label: 'Hospital', pillBg: pillBg, pillText: pillText),
          const SizedBox(height: 14),

          // Contact Rows
          ...contacts.map((contact) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _makePhoneCall(contact.number),
                onLongPress: () =>
                    _copyToClipboard(contact.number, contact.name),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.5,
                              fontFamily: AppTheme.fontGeneralSans,
                              color: textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: '${contact.name} : ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: contact.number,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: highlightBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: highlightBlue,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. ACCOMMODATION CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildAccommodationCard({
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color pillBg,
    required Color pillText,
    required Color highlightBlue,
  }) {
    final contacts = HelpCenterData.accommodationContacts;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag Pill
          _buildPillTag(
              label: 'Accomodation', pillBg: pillBg, pillText: pillText),
          const SizedBox(height: 14),

          // Contact Rows
          ...contacts.map((contact) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _makePhoneCall(contact.number),
                onLongPress: () =>
                    _copyToClipboard(contact.number, contact.name),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.5,
                              fontFamily: AppTheme.fontGeneralSans,
                              color: textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: '${contact.name}: ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: contact.number,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: highlightBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: highlightBlue,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. TRANSPORT CARD & TIME SLOTS TABLE
  // ─────────────────────────────────────────────────────────────
  Widget _buildTransportCard({
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color pillBg,
    required Color pillText,
    required Color highlightBlue,
  }) {
    final contacts = HelpCenterData.transportContacts;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag Pill
          _buildPillTag(label: 'Transport', pillBg: pillBg, pillText: pillText),
          const SizedBox(height: 14),

          // Table Header: Contacts & Time Slot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contacts',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.fontGeneralSans,
                  color: textPrimary,
                ),
              ),
              Text(
                'Time Slot',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.fontGeneralSans,
                  color: textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: cardBorder, height: 1),
          const SizedBox(height: 10),

          // Transport Rows
          ...contacts.map((contact) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _makePhoneCall(contact.number),
                onLongPress: () =>
                    _copyToClipboard(contact.number, contact.name),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Contact label & number
                      Expanded(
                        flex: 6,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13.5,
                              fontFamily: AppTheme.fontGeneralSans,
                              color: textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: '${contact.name}: ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: contact.number,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: highlightBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Time Slot
                      Expanded(
                        flex: 4,
                        child: Text(
                          contact.timeSlot ?? 'Time Slot',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppTheme.fontGeneralSans,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 4. FAQS ACCORDION
  // ─────────────────────────────────────────────────────────────
  Widget _buildFaqsSection({
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final faqs = HelpCenterData.faqs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FAQs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontUnivers,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        // Accordion Cards
        ...faqs.asMap().entries.map((entry) {
          final idx = entry.key;
          final faq = entry.value;
          final isExpanded = _expandedFaqIndices.contains(idx);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedFaqIndices.remove(idx);
                    } else {
                      _expandedFaqIndices.add(idx);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq.question,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppTheme.fontGeneralSans,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: textSecondary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        Divider(color: cardBorder, height: 1),
                        const SizedBox(height: 12),
                        Text(
                          faq.answer,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: textSecondary,
                            fontFamily: AppTheme.fontGeneralSans,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 5. SOCIALS SECTION (APP ICON BUTTONS)
  // ─────────────────────────────────────────────────────────────
  Widget _buildSocialsSection({
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final socials = HelpCenterData.socials;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Socials',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontUnivers,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        // Horizontal Row of 5 Squarish Rounded Logo Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: socials.map((item) {
            return _buildSocialAppButton(
              item: item,
              isDark: isDark,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSocialAppButton({
    required HelpSocialLink item,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => _launchExternalUrl(item.url),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    Color(0xFF3355A6),
                    Color(0xFF233B78),
                  ]
                : const [
                    Color(0xFFE4F0FF),
                    Color(0xFFD3E6FD),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: isDark
                ? const Color(0xFF4C75D0).withOpacity(0.5)
                : const Color(0xFFBEDBFE),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF1D3570).withOpacity(0.4)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            item.iconAsset,
            width: 26,
            height: 26,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.share_outlined,
              color: isDark ? Colors.white : const Color(0xFF1E40AF),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // REUSABLE PILL TAG
  // ─────────────────────────────────────────────────────────────
  Widget _buildPillTag({
    required String label,
    required Color pillBg,
    required Color pillText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFamily: AppTheme.fontGeneralSans,
          color: pillText,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
