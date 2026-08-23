import 'package:flutter/material.dart';
import '../../../constant/appTheme.dart';
import '../../../providers/comedy_provider.dart';

class ComedyPreRegistrationView extends StatelessWidget {
  final bool isDark;
  final bool registrationOpen;
  final DateTime? registrationStartTime;
  final Duration timeLeft;
  final ComedyState comedyState;
  final VoidCallback onRegisterTap;

  const ComedyPreRegistrationView({
    super.key,
    required this.isDark,
    required this.registrationOpen,
    required this.registrationStartTime,
    required this.timeLeft,
    required this.comedyState,
    required this.onRegisterTap,
  });

  String _formatRegistrationDate(DateTime? dt) {
    if (dt == null) return '29th August 2026';
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = monthNames[dt.month - 1];
    final day = dt.day;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day $month ${dt.year} • $hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hero Banner
        _buildHeroBanner(isDark),

        const SizedBox(height: 20),

        // 2. Registration & Countdown Status Card
        _buildRegistrationStatusCard(context, isDark),

        const SizedBox(height: 20),

        // 3. Entry Guidelines Card
        _buildGuidelinesCard(isDark),

        const SizedBox(height: 32),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. HERO SHOWCASE BANNER
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeroBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Techniche Comedy Night 2026',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.fontUnivers,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'An unforgettable evening of live stand-up comedy featuring top celebrity artists at IIT Guwahati.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontFamily: AppTheme.fontGeneralSans,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppTheme.primaryBlue),
              const SizedBox(width: 6),
              Text(
                _formatRegistrationDate(registrationStartTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontFamily: AppTheme.fontGeneralSans,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 15, color: AppTheme.primaryBlue),
              SizedBox(width: 6),
              Text(
                'Dr. Bhupen Hazarika Auditorium, IIT Guwahati',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontFamily: AppTheme.fontGeneralSans,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 2. REGISTRATION STATUS & COUNTDOWN CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildRegistrationStatusCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? AppTheme.darkCardsBg : AppTheme.lightCardsBg;
    final cardBorder =
        isDark ? const Color(0xFF282846) : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!registrationOpen &&
              registrationStartTime != null &&
              !timeLeft.isNegative &&
              timeLeft > Duration.zero) ...[
            const Text(
              'REGISTRATION OPENS IN',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontUnivers,
                letterSpacing: 1.0,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            _buildCountdownTimerWidget(isDark),
            const SizedBox(height: 14),
            Text(
              'Pass claims will automatically unlock when the countdown finishes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontFamily: AppTheme.fontGeneralSans,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
              ),
            ),
          ] else if (!registrationOpen) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_clock_rounded,
                      color: Color(0xFFF59E0B), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'REGISTRATIONS OPENING SOON',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontUnivers,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Registration slots are live-controlled via Remote Config. Stay tuned for updates!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontFamily: AppTheme.fontGeneralSans,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
              ),
            ),
          ] else ...[
            const Text(
              'REGISTRATIONS ARE LIVE!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontUnivers,
                letterSpacing: 1.0,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: comedyState.isLoading ? 0 : 4,
                ),
                onPressed: comedyState.isLoading ? null : onRegisterTap,
                child: comedyState.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'CLAIM ENTRY PASS NOW',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // COUNTDOWN TIMER BLOCKS
  // ─────────────────────────────────────────────────────────────
  Widget _buildCountdownTimerWidget(bool isDark) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = twoDigits(timeLeft.inDays);
    final hours = twoDigits(timeLeft.inHours.remainder(24));
    final minutes = twoDigits(timeLeft.inMinutes.remainder(60));
    final seconds = twoDigits(timeLeft.inSeconds.remainder(60));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimerBlock(days, 'Days', isDark),
        _buildTimerDivider(),
        _buildTimerBlock(hours, 'Hours', isDark),
        _buildTimerDivider(),
        _buildTimerBlock(minutes, 'Mins', isDark),
        _buildTimerDivider(),
        _buildTimerBlock(seconds, 'Secs', isDark),
      ],
    );
  }

  Widget _buildTimerBlock(String value, String label, bool isDark) {
    final blockBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final textPrimary =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: blockBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.3),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: AppTheme.fontUnivers,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
            fontSize: 10,
            fontFamily: AppTheme.fontGeneralSans,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 4.0, right: 4.0, bottom: 18.0),
      child: Text(
        ':',
        style: TextStyle(
          color: AppTheme.primaryBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3. GUIDELINES & RULES CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildGuidelinesCard(bool isDark) {
    final cardBg = isDark ? AppTheme.darkCardsBg : AppTheme.lightCardsBg;
    final cardBorder =
        isDark ? const Color(0xFF282846) : const Color(0xFFE2E8F0);
    final textPrimary =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    final rules = [
      'Please complete your profile in order to register.',
      'Write your IITG email in your profile else your registration gets cancelled.',
      'Seating is on a first-come, first-served basis; arrive early.',
      'Show your digital QR code pass at the auditorium main gate for scanning.',
      'A valid Techniche 26 Registration ID or IITG Roll Number is mandatory.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ENTRY GUIDELINES',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTheme.fontUnivers,
                  letterSpacing: 0.8,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...rules.map((rule) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      rule,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontFamily: AppTheme.fontGeneralSans,
                        color: textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
