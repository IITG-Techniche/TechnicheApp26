import 'package:flutter/material.dart';
import '../../../constant/appTheme.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/comedy_provider.dart';

class ComedyWaitlistTicketView extends StatelessWidget {
  final bool isDark;
  final UserState userState;
  final ComedyState comedyState;
  final VoidCallback onRefreshTap;

  const ComedyWaitlistTicketView({
    super.key,
    required this.isDark,
    required this.userState,
    required this.comedyState,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppTheme.darkCardsBg : Colors.white;
    const cardBorder = Color(0xFFF59E0B);
    final textPrimary =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textSecondary =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder, width: 1.5),
              color: cardBg,
              boxShadow: [
                BoxShadow(
                  color: cardBorder.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top header bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: cardBorder.withOpacity(0.1),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PASS REQUEST SUBMITTED',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          comedyState.status.isEmpty
                              ? 'WAITLISTED'
                              : comedyState.status,
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTheme.fontUnivers,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Event Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Techniche Comedy Night 2026',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTheme.fontUnivers,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '29th August 2026 • 8:00 PM Onwards',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          fontFamily: AppTheme.fontGeneralSans,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Dr. Bhupen Hazarika Auditorium, IIT Guwahati',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 13,
                          fontFamily: AppTheme.fontGeneralSans,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Divider(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1),
                      ),
                      const SizedBox(height: 12),

                      // Attendee details
                      _buildTicketInfoRow('ATTENDEE', userState.name,
                          textPrimary, textSecondary),
                      _buildTicketInfoRow('ROLL NUMBER', userState.rollNumber,
                          textPrimary, textSecondary),
                      _buildTicketInfoRow('COLLEGE EMAIL', userState.collegeEmail,
                          textPrimary, textSecondary),
                    ],
                  ),
                ),

                // Dotted Ticket Separator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0
                              ? Colors.transparent
                              : (isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.15)),
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                // Waitlist Status Explanation
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 24.0, left: 20, right: 20),
                  child: Column(
                    children: [
                      const Icon(Icons.hourglass_empty_rounded,
                          color: Colors.amber, size: 38),
                      const SizedBox(height: 10),
                      Text(
                        'PASS REQUEST IN REVIEW',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          fontFamily: AppTheme.fontUnivers,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Registrations are reviewed in batches. Once confirmed by organizers, your entry QR code will generate here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11.5,
                          fontFamily: AppTheme.fontGeneralSans,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Refresh status button
          TextButton.icon(
            icon: const Icon(Icons.refresh_rounded,
                color: AppTheme.primaryBlue, size: 20),
            label: const Text(
              'Refresh Ticket Status',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
                fontFamily: AppTheme.fontGeneralSans,
              ),
            ),
            onPressed: onRefreshTap,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTicketInfoRow(
    String label,
    String value,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: AppTheme.fontUnivers,
            ),
          ),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: TextStyle(
              color: textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              fontFamily: AppTheme.fontGeneralSans,
            ),
          ),
        ],
      ),
    );
  }
}
