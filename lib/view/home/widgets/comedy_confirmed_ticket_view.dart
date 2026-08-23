import 'package:flutter/material.dart';
import '../../../constant/appTheme.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/comedy_provider.dart';

class ComedyConfirmedTicketView extends StatelessWidget {
  final bool isDark;
  final UserState userState;
  final ComedyState comedyState;
  final VoidCallback onRefreshTap;

  const ComedyConfirmedTicketView({
    super.key,
    required this.isDark,
    required this.userState,
    required this.comedyState,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppTheme.darkCardsBg : Colors.white;
    const cardBorder = Color(0xFF10B981);
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
                  color: cardBorder.withOpacity(0.2),
                  blurRadius: 18,
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
                    color: cardBorder.withOpacity(0.12),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OFFICIAL ENTRY PASS',
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
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Color(0xFF10B981), size: 13),
                            SizedBox(width: 4),
                            Text(
                              'SEAT CONFIRMED',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppTheme.fontUnivers,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Event Information
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

                // Barcode / Ticket Code Section
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 24.0, left: 20, right: 20),
                  child: Column(
                    children: [
                      Container(
                        height: 56,
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            36,
                            (index) => Container(
                              width: (index % 3 == 0)
                                  ? 3.5
                                  : (index % 5 == 0 ? 1 : 2),
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        comedyState.ticketCode ?? 'TCH26-COMEDY-PASS',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          fontFamily: AppTheme.fontUnivers,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Present this digital barcode pass at the main gate for entrance scanning.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11.5,
                          fontFamily: AppTheme.fontGeneralSans,
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
              'Refresh Pass Status',
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
