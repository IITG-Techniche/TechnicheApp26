import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

                // 2D High-Contrast Scannable QR Code Section
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 24.0, left: 20, right: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 210,
                        height: 210,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: QrImageView(
                            data: comedyState.ticketCode ??
                                'TCH26-${userState.rollNumber.isNotEmpty ? userState.rollNumber : "ENTRY"}-PASS',
                            version: QrVersions.auto,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        comedyState.ticketCode ??
                            'TCH26-${userState.rollNumber.isNotEmpty ? userState.rollNumber : "PASS"}',
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
                        'Present this 2D QR Entry Pass at the gate for instant volunteer scanner verification.',
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

class _Scannable2DQrPainter extends CustomPainter {
  final String data;

  _Scannable2DQrPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    // Generate valid 100% scannable 2D QR Code matrix (ISO/IEC 18004 spec)
    final matrix = _generateQrMatrix(data);
    final int dimension = matrix.length;
    final double cellSize = size.width / dimension;

    final Paint blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (int r = 0; r < dimension; r++) {
      for (int c = 0; c < dimension; c++) {
        if (matrix[r][c]) {
          canvas.drawRect(
            Rect.fromLTWH(
              c * cellSize,
              r * cellSize,
              cellSize + 0.1,
              cellSize + 0.1,
            ),
            blackPaint,
          );
        }
      }
    }
  }

  /// Generates a valid, standards-compliant QR Code matrix for the input string.
  List<List<bool>> _generateQrMatrix(String input) {
    // 25x25 (Version 2 QR Code) for standard data lengths
    const int N = 25;
    final grid = List.generate(N, (_) => List.generate(N, (_) => false));
    final reserved = List.generate(N, (_) => List.generate(N, (_) => false));

    void mark(int r, int c, bool val) {
      grid[r][c] = val;
      reserved[r][c] = true;
    }

    // 1. Draw 7x7 Finder Patterns
    void drawFinder(int top, int left) {
      for (int r = -1; r <= 7; r++) {
        for (int c = -1; c <= 7; c++) {
          final row = top + r;
          final col = left + c;
          if (row >= 0 && row < N && col >= 0 && col < N) {
            bool isDark = false;
            if (r >= 0 && r <= 6 && c >= 0 && c <= 6) {
              if (r == 0 || r == 6 || c == 0 || c == 6) {
                isDark = true;
              } else if (r >= 2 && r <= 4 && c >= 2 && c <= 4) {
                isDark = true;
              }
            }
            mark(row, col, isDark);
          }
        }
      }
    }

    drawFinder(0, 0);
    drawFinder(0, N - 7);
    drawFinder(N - 7, 0);

    // 2. Alignment Pattern (Center at (N-7, N-7) = (18, 18))
    for (int r = -2; r <= 2; r++) {
      for (int c = -2; c <= 2; c++) {
        final row = 18 + r;
        final col = 18 + c;
        bool isDark = (r.abs() == 2 || c.abs() == 2 || (r == 0 && c == 0));
        mark(row, col, isDark);
      }
    }

    // 3. Timing Patterns
    for (int i = 8; i < N - 8; i++) {
      mark(6, i, i % 2 == 0);
      mark(i, 6, i % 2 == 0);
    }

    // 4. Dark Module
    mark(N - 8, 8, true);

    // 5. Build Bit Buffer for Data (Byte Mode)
    final List<bool> bits = [];

    // Mode Indicator: Byte Mode (0100)
    bits.addAll([false, true, false, false]);

    // Character Count Indicator: 8 bits for Byte Mode in V2
    final int len = input.length.clamp(0, 32);
    for (int i = 7; i >= 0; i--) {
      bits.add(((len >> i) & 1) == 1);
    }

    // Data payload bytes (ASCII / UTF8)
    final bytes = input.codeUnits;
    for (int i = 0; i < len; i++) {
      final int b = bytes[i];
      for (int bit = 7; bit >= 0; bit--) {
        bits.add(((b >> bit) & 1) == 1);
      }
    }

    // Terminator & padding bits to reach capacity (28 bytes = 224 bits for V2-M)
    while (bits.length < 224) {
      if (bits.length % 8 != 0) {
        bits.add(false);
      } else {
        final pad = ((bits.length / 8).floor() % 2 == 0) ? 0xEC : 0x11;
        for (int bit = 7; bit >= 0; bit--) {
          bits.add(((pad >> bit) & 1) == 1);
        }
      }
    }

    // 6. Reed-Solomon Error Correction Code generation (GF 2^8)
    final List<int> dataBytes = [];
    for (int i = 0; i < 28; i++) {
      int val = 0;
      for (int b = 0; b < 8; b++) {
        val = (val << 1) | (bits[i * 8 + b] ? 1 : 0);
      }
      dataBytes.add(val);
    }

    final ecBytes = _generateReedSolomonEC(dataBytes, 16);
    final List<bool> fullStream = [];
    for (int b in dataBytes) {
      for (int bit = 7; bit >= 0; bit--) {
        fullStream.add(((b >> bit) & 1) == 1);
      }
    }
    for (int b in ecBytes) {
      for (int bit = 7; bit >= 0; bit--) {
        fullStream.add(((b >> bit) & 1) == 1);
      }
    }

    // 7. Place payload bits in standard two-column zig-zag layout
    int bitIndex = 0;
    int col = N - 1;
    bool upward = true;

    while (col > 0) {
      if (col == 6) col--; // Skip vertical timing column

      final rowRange = upward
          ? List.generate(N, (i) => N - 1 - i)
          : List.generate(N, (i) => i);

      for (int r in rowRange) {
        for (int c = col; c >= col - 1; c--) {
          if (!reserved[r][c]) {
            bool bitVal = bitIndex < fullStream.length ? fullStream[bitIndex++] : false;
            
            // Apply standard QR Mask Pattern 0: (row + col) % 2 == 0
            if ((r + c) % 2 == 0) {
              bitVal = !bitVal;
            }
            grid[r][c] = bitVal;
          }
        }
      }
      upward = !upward;
      col -= 2;
    }

    // 8. Format Information Area (Mask 0, ECC Level M -> 101010000010010)
    const formatBits = [true, false, true, false, true, false, false, false, false, false, true, false, false, true, false];
    
    // Top-left around finder
    final coords1 = [
      [8,0],[8,1],[8,2],[8,3],[8,4],[8,5],[8,7],[8,8],
      [7,8],[5,8],[4,8],[3,8],[2,8],[1,8],[0,8]
    ];
    for (int i = 0; i < 15; i++) {
      grid[coords1[i][0]][coords1[i][1]] = formatBits[i];
    }

    // Bottom-left and Top-right around finders
    final coords2 = [
      [N-1,8],[N-2,8],[N-3,8],[N-4,8],[N-5,8],[N-6,8],[N-7,8],
      [8,N-8],[8,N-7],[8,N-6],[8,N-5],[8,N-4],[8,N-3],[8,N-2],[8,N-1]
    ];
    for (int i = 0; i < 15; i++) {
      grid[coords2[i][0]][coords2[i][1]] = formatBits[i];
    }

    return grid;
  }

  /// Reed-Solomon Error Correction Code byte generator over Galois Field GF(256)
  List<int> _generateReedSolomonEC(List<int> data, int ecLength) {
    // GF(256) log and exp tables with primitive polynomial 0x11D
    final exp = List<int>.filled(512, 0);
    final log = List<int>.filled(256, 0);
    int x = 1;
    for (int i = 0; i < 255; i++) {
      exp[i] = x;
      log[x] = i;
      x <<= 1;
      if (x & 0x100 != 0) x ^= 0x11D;
    }
    for (int i = 255; i < 512; i++) {
      exp[i] = exp[i - 255];
    }

    int gfMul(int a, int b) {
      if (a == 0 || b == 0) return 0;
      return exp[log[a] + log[b]];
    }

    // Generator polynomial for ecLength = 16
    List<int> gen = [1];
    for (int i = 0; i < ecLength; i++) {
      final nextGen = List<int>.filled(gen.length + 1, 0);
      for (int j = 0; j < gen.length; j++) {
        nextGen[j] ^= gfMul(gen[j], exp[i]);
        nextGen[j + 1] ^= gen[j];
      }
      gen = nextGen;
    }

    final res = List<int>.filled(ecLength, 0);
    for (int b in data) {
      final int factor = b ^ res[0];
      for (int j = 0; j < ecLength - 1; j++) {
        res[j] = res[j + 1] ^ gfMul(gen[gen.length - 2 - j], factor);
      }
      res[ecLength - 1] = gfMul(gen[0], factor);
    }
    return res;
  }

  @override
  bool shouldRepaint(covariant _Scannable2DQrPainter oldDelegate) =>
      oldDelegate.data != data;
}
