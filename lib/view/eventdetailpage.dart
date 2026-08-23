import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../constant/appTheme.dart';
import '../model/events_data.dart';
import 'core/map_screen.dart';
import '../features/event_reminders/presentation/reminder_picker_sheet.dart';
import '../features/event_reminders/domain/reminder_manager.dart';
import '../features/event_reminders/domain/event_reminder.dart';

class EventDetailPage extends StatefulWidget {
  final String eventTitle;
  final EventDetail? event;

  const EventDetailPage({
    super.key,
    required this.eventTitle,
    this.event,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late final EventDetail _event;
  bool _isDescriptionExpanded = false;
  final Set<int> _expandedRounds = {};
  final Set<int> _expandedFaqs = {};

  EventReminder? _activeReminder;

  @override
  void initState() {
    super.initState();
    _event = widget.event ??
        findEventByTitle(widget.eventTitle) ??
        EventDetail(
          title: widget.eventTitle,
          description:
              '${widget.eventTitle}, a major event at Techniche, showcases top talents in engineering and technology through intense competition. Participants design and develop solutions to engage in high-level challenges within IIT Guwahati.',
          venue: 'L1 - Lecture Hall, Near Academic Block',
          date: '25th Aug - 6th Sep, 2026',
        );
    _checkReminderStatus();
  }

  Future<void> _checkReminderStatus() async {
    final reminder = await ReminderManager().getReminder(_event.effectiveId);
    if (mounted) {
      setState(() {
        _activeReminder = reminder;
      });
    }
  }

  Future<void> _launchExternalUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse(
        'mailto:$email?subject=${Uri.encodeComponent(_event.title)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareEvent() {
    final text = 'Check out ${_event.title} at Techniche 2026, IIT Guwahati!\n'
        '${_event.description ?? ''}\n'
        'Register here: ${_event.redirectUrl ?? 'https://techniche.org.in'}';
    Share.share(text);
  }

  void _openTechnicheMap(String? venue) {
    if (venue == null || venue.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(initialVenue: venue),
      ),
    );
  }

  void _setReminder() {
    ReminderPickerSheet.show(
      context,
      event: _event,
      onReminderUpdated: _checkReminderStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Palette tokens matching 2026 specs exactly in both Dark & Light themes
    final bgColor = isDark ? AppTheme.darkPageBg : AppTheme.lightPageBg;
    final cardBg = isDark ? AppTheme.darkCardsBg : AppTheme.lightCardsBg;
    final cardBorder =
        isDark ? const Color(0xFF282846) : const Color(0xFFE5E7EB);
    final textPrimary =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final iconContainerBg =
        isDark ? const Color(0xFF1E284A) : AppTheme.lightChip;
    final primaryBlue = AppTheme.primaryBlue;
    final pillBg = isDark ? const Color(0xFF222942) : AppTheme.lightChip;
    final dummyImageBg =
        isDark ? const Color(0xFF20263A) : const Color(0xFFD9D9D9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Top Image Banner with Back Button & Title ──
            _buildTopBanner(context),

            // ── 2. Overlapping Info & Schedule Card ──
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildOverviewCard(
                      isDark: isDark,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      iconContainerBg: iconContainerBg,
                      primaryBlue: primaryBlue,
                      pillBg: pillBg,
                    ),

                    const SizedBox(height: 24),

                    // ── 3. Event Details & Expandable Description ──
                    _buildEventDetailsSection(
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      primaryBlue: primaryBlue,
                      dummyImageBg: dummyImageBg,
                    ),

                    if (_event.whoCanParticipate.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildWhoCanParticipateSection(
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],

                    if (_event.rules.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildRulesSection(
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],

                    if (_event.faqs.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildFaqsSection(
                        isDark: isDark,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],

                    if (_event.coordinators.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildPersonOfContactCard(
                        isDark: isDark,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        iconContainerBg: iconContainerBg,
                        primaryBlue: primaryBlue,
                      ),
                    ],

                    if (_event.prizeCategories.isNotEmpty ||
                        (_event.prizeBreakdown != null &&
                            _event.prizeBreakdown!.isNotEmpty)) ...[
                      const SizedBox(height: 28),
                      _buildPrizesSection(
                        isDark: isDark,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        iconContainerBg: iconContainerBg,
                      ),
                    ],

                    if (_event.whatsappUrl != null &&
                        _event.whatsappUrl!.trim().isNotEmpty) ...[
                      const SizedBox(height: 28),
                      _buildWhatsAppSection(primaryBlue: primaryBlue),
                    ],

                    const SizedBox(height: 48),
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
  // 1. TOP BANNER
  // ─────────────────────────────────────────────────────────────
  Widget _buildTopBanner(BuildContext context) {
    final imageAsset = _event.imageAsset ?? 'assets/robotics.jpeg';

    return Stack(
      children: [
        Container(
          height: 290,
          width: double.infinity,
          color: const Color(0xFF1E2235),
          child: Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF002B5B),
                child: Center(
                  child: Icon(
                    Icons.smart_toy_outlined,
                    size: 72,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
        ),

        // Dark gradient overlay for top bar visibility
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // Top Navigation Bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: AppTheme.fontUnivers,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.share_outlined,
                      color: Colors.white, size: 22),
                  onPressed: _shareEvent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. OVERVIEW & SCHEDULE CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildOverviewCard({
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color iconContainerBg,
    required Color primaryBlue,
    required Color pillBg,
  }) {
    final locationText = _event.venue;
    final mapUrl = _event.mapLocationUrl ??
        (locationText != null ? 'https://maps.google.com/?q=${Uri.encodeComponent(locationText)}' : null);
    final hasLocation = locationText != null && locationText.trim().isNotEmpty;
    final rounds = _event.rounds;
    final hasRounds = rounds.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Location Row ──
          if (hasLocation) ...[
            InkWell(
              onTap: () => _openTechnicheMap(locationText),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconContainerBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF175BCC),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locationText!,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppTheme.fontGeneralSans,
                              color: textPrimary,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Show on Techniche Map',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppTheme.fontGeneralSans,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: primaryBlue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasRounds) const SizedBox(height: 20),
          ],

          // ── Schedule Section Header ──
          if (hasRounds) ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconContainerBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF175BCC),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTheme.fontUnivers,
                    color: textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Vertical Timeline of Rounds ──
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Column(
                children: rounds.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final round = entry.value;
                  final isLast = idx == rounds.length - 1;
                  final isExpanded = _expandedRounds.contains(idx);

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline indicator line & dot
                        Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Round Card & Subtitle
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedRounds.remove(idx);
                                      } else {
                                        _expandedRounds.add(idx);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: pillBg,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            round.title,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              fontFamily:
                                                  AppTheme.fontGeneralSans,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons.keyboard_arrow_down_rounded,
                                          color: textPrimary,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isExpanded &&
                                    round.description != null) ...[
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text(
                                      round.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textSecondary,
                                        fontFamily:
                                            AppTheme.fontGeneralSans,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    '${round.time}  |  ${round.date}',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          AppTheme.fontGeneralSans,
                                      color: textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // ── Dotted Divider with center handle ──
            _buildDottedSeparator(isDark: isDark),

            const SizedBox(height: 16),
          ],

          // ── Action Row: "Register now !" + Buttons ──
          Text(
            'Register now !',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              fontFamily: AppTheme.fontGeneralSans,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Register Button
              Expanded(
                flex: 5,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      final url = _event.redirectUrl ??
                          'https://unstop.com/techniche-2026';
                      _launchExternalUrl(url);
                    },
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTheme.fontUnivers,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Set Reminder Button
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      backgroundColor: _activeReminder != null
                          ? primaryBlue.withOpacity(isDark ? 0.25 : 0.12)
                          : (isDark
                              ? const Color(0xFF20263C)
                              : const Color(0xFFF3F4F6)),
                      side: BorderSide(
                        color: _activeReminder != null
                            ? primaryBlue
                            : (isDark
                                ? const Color(0xFF2D3550)
                                : const Color(0xFFE5E7EB)),
                        width: _activeReminder != null ? 1.5 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _setReminder,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            _activeReminder != null
                                ? 'Remind ${_activeReminder!.offsetMinutes}m before'
                                : 'Set Reminder',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppTheme.fontGeneralSans,
                              color: _activeReminder != null
                                  ? primaryBlue
                                  : textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _activeReminder != null
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          color: _activeReminder != null
                              ? primaryBlue
                              : const Color(0xFF2563EB),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. EVENT DETAILS SECTION & DUMMY IMAGE GALLERY
  // ─────────────────────────────────────────────────────────────
  Widget _buildEventDetailsSection({
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryBlue,
    required Color dummyImageBg,
  }) {
    final desc = _event.description;
    final hasDesc = desc != null && desc.trim().isNotEmpty;
    final hasImage = _event.imageAsset != null && _event.imageAsset!.trim().isNotEmpty;

    if (!hasDesc && !hasImage) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDesc) ...[
          Text(
            'Event Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.fontUnivers,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc!,
            maxLines: _isDescriptionExpanded ? null : 4,
            overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppTheme.fontGeneralSans,
              color: textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Text(
                _isDescriptionExpanded ? '- Read Less' : '+ Read More',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.fontGeneralSans,
                  color: primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

      ],
    );
  }


  // ─────────────────────────────────────────────────────────────
  // 4. WHO ALL CAN PARTICIPATE ?
  // ─────────────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────
  // 4. WHO ALL CAN PARTICIPATE ?
  // ─────────────────────────────────────────────────────────────
  Widget _buildWhoCanParticipateSection({
    required Color textPrimary,
    required Color textSecondary,
  }) {
    if (_event.whoCanParticipate.isEmpty) return const SizedBox.shrink();
    final list = _event.whoCanParticipate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who all can participate ?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontUnivers,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...list.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 10),
                  child: Text(
                    '•',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: AppTheme.fontGeneralSans,
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 5. RULES
  // ─────────────────────────────────────────────────────────────
  Widget _buildRulesSection({
    required Color textPrimary,
    required Color textSecondary,
  }) {
    if (_event.rules.isEmpty) return const SizedBox.shrink();
    final rules = _event.rules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rules',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontUnivers,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...rules.map((rule) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 10),
                  child: Text(
                    '•',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rule,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: AppTheme.fontGeneralSans,
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 6. FAQS ACCORDION
  // ─────────────────────────────────────────────────────────────
  Widget _buildFaqsSection({
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    if (_event.faqs.isEmpty) return const SizedBox.shrink();
    final faqs = _event.faqs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FAQs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontUnivers,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            children: faqs.asMap().entries.map((entry) {
              final idx = entry.key;
              final faq = entry.value;
              final isLast = idx == faqs.length - 1;
              final isExpanded = _expandedFaqs.contains(idx);

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedFaqs.remove(idx);
                        } else {
                          _expandedFaqs.add(idx);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq.question,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppTheme.fontGeneralSans,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: textSecondary,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          faq.answer,
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            fontFamily: AppTheme.fontGeneralSans,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                  if (!isLast)
                    Divider(height: 1, color: cardBorder),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 7. PERSON OF CONTACT CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildPersonOfContactCard({
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color iconContainerBg,
    required Color primaryBlue,
  }) {
    if (_event.coordinators.isEmpty) return const SizedBox.shrink();
    final coordinator = _event.coordinators.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconContainerBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF175BCC),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'PERSON OF CONTACT',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.fontUnivers,
                  letterSpacing: 0.8,
                  color: textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Name
          Text(
            'Name',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: AppTheme.fontGeneralSans,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            coordinator.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.fontUnivers,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 14),

          // Phone Number
          Text(
            'Phone number',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: AppTheme.fontGeneralSans,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          GestureDetector(
            onTap: () => _makePhoneCall(coordinator.phone),
            child: Text(
              coordinator.phone,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                fontFamily: AppTheme.fontGeneralSans,
                color: primaryBlue,
              ),
            ),
          ),

          if (coordinator.email != null) ...[
            const SizedBox(height: 14),
            Text(
              'Email',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: AppTheme.fontGeneralSans,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            GestureDetector(
              onTap: () => _sendEmail(coordinator.email!),
              child: Text(
                coordinator.email!,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontGeneralSans,
                  color: primaryBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 8. PRIZES SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildPrizesSection({
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color iconContainerBg,
  }) {
    final hasCategories = _event.prizeCategories.isNotEmpty;
    final hasBreakdown =
        _event.prizeBreakdown != null && _event.prizeBreakdown!.isNotEmpty;

    if (!hasCategories && !hasBreakdown) {
      return const SizedBox.shrink();
    }
    final categories = _event.prizeCategories;
    final breakdown = _event.prizeBreakdown ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconContainerBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFF175BCC),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'PRIZES',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontUnivers,
                letterSpacing: 0.8,
                color: textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasCategories)
                ...categories.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final cat = entry.value;
                  final isLast = idx == categories.length - 1 && !hasBreakdown;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.categoryName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...cat.prizes.entries.map((prizeEntry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prizeEntry.key,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppTheme.fontGeneralSans,
                                  color: textSecondary,
                                ),
                              ),
                              Text(
                                prizeEntry.value,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppTheme.fontUnivers,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (!isLast) ...[
                        const SizedBox(height: 14),
                        _buildDashedLine(isDark: isDark),
                        const SizedBox(height: 16),
                      ],
                    ],
                  );
                }),
              if (hasBreakdown)
                ...breakdown.entries.map((prizeEntry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          prizeEntry.key,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppTheme.fontGeneralSans,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          prizeEntry.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTheme.fontUnivers,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 9. WHATSAPP GROUP SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildWhatsAppSection({required Color primaryBlue}) {
    if (_event.whatsappUrl == null || _event.whatsappUrl!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final whatsappUrl = _event.whatsappUrl!;

    return GestureDetector(
      onTap: () => _launchExternalUrl(whatsappUrl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE1EBFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Color(0xFF175BCC),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Join the WhatsApp Group',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                fontFamily: AppTheme.fontGeneralSans,
                color: primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS: Dotted & Dashed Lines
  // ─────────────────────────────────────────────────────────────
  Widget _buildDottedSeparator({required bool isDark}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        final dotColor =
            isDark ? const Color(0xFF333B56) : const Color(0xFFD1D5DB);

        return Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: dashWidth,
                  height: dashHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: dotColor),
                  ),
                );
              }),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF161A29) : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashedLine({required bool isDark}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 6.0;
        const dashHeight = 1.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        final dashColor =
            isDark ? const Color(0xFF2D354E) : const Color(0xFFE5E7EB);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: dashColor),
              ),
            );
          }),
        );
      },
    );
  }
}