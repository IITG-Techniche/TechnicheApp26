import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/events_data.dart';
import '../../constant/appTheme.dart';
import '../../providers/theme_provider.dart';
import 'sub_category_screen.dart';

class EventsScreen extends StatefulWidget {
  static const String routeName = '/events';
  final bool isTab;

  const EventsScreen({
    super.key,
    this.isTab = false,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppTheme.darkPageBg : AppTheme.lightPageBg;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, textPrimary: textPrimary),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: _buildStaggeredCategoryGrid(context, isDark: isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required Color textPrimary}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.isTab) {
                Scaffold.of(context).openDrawer();
              } else {
                Navigator.maybePop(context);
              }
            },
            child: Icon(
              widget.isTab ? Icons.menu_rounded : Icons.chevron_left_rounded,
              color: textPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Events',
              style: TextStyle(
                color: textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: AppTheme.fontUnivers,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, _) {
              final themeMode = ref.watch(themeModeProvider);
              final isDark = themeMode == ThemeMode.dark;
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1E38) : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  icon: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: isDark ? Colors.amber : const Color(0xFF30499E),
                    size: 20,
                  ),
                  onPressed: () {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredCategoryGrid(BuildContext context, {required bool isDark}) {
    if (eventData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No event categories available',
            style: TextStyle(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              fontFamily: AppTheme.fontGeneralSans,
            ),
          ),
        ),
      );
    }

    final leftCol = <int>[];
    final rightCol = <int>[];

    for (int i = 0; i < eventData.length; i++) {
      if (i % 2 == 0) {
        leftCol.add(i);
      } else {
        rightCol.add(i);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftCol.map((index) {
              final cat = eventData[index];
              final double cardHeight = _getCardHeight(cat.title, index, isLeft: true);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _CategoryCard(
                  category: cat,
                  height: cardHeight,
                  isDark: isDark,
                  onTap: () => _onCategoryTap(context, cat),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: rightCol.map((index) {
              final cat = eventData[index];
              final double cardHeight = _getCardHeight(cat.title, index, isLeft: false);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _CategoryCard(
                  category: cat,
                  height: cardHeight,
                  isDark: isDark,
                  onTap: () => _onCategoryTap(context, cat),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  double _getCardHeight(String title, int index, {required bool isLeft}) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('competition')) return 270;
    if (lowerTitle.contains('workshop')) return 170;
    if (lowerTitle.contains('nexus')) return 165;
    if (lowerTitle.contains('lecture')) return 240;
    if (lowerTitle.contains('exhibition')) return 220;
    return isLeft ? 240 : 190;
  }

  void _onCategoryTap(BuildContext context, MainCategory category) {
    Navigator.pushNamed(
      context,
      SubCategoryScreen.routeName,
      arguments: {
        'categoryTitle': category.title,
        'subCategories': category.subCategories,
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final MainCategory category;
  final double height;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.height,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = AppTheme.darkCardsBg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardBg.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: _CategoryGraphic(categoryTitle: category.title),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Text(
                category.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontGeneralSans,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGraphic extends StatelessWidget {
  final String categoryTitle;

  const _CategoryGraphic({required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    final lower = categoryTitle.toLowerCase();

    if (lower.contains('competition')) {
      return Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ArchedLinesPainter(
                color: const Color(0xFF8B5CF6).withOpacity(0.4),
                arcCount: 5,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            height: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/robo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF232542),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.white54, size: 40),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (lower.contains('workshop')) {
      return Stack(
        children: [
          Positioned(
            bottom: -10,
            right: -10,
            width: 140,
            height: 110,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(20),
              ),
              child: Image.asset(
                'assets/robotics.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF232542),
                  child: const Icon(Icons.build_rounded, color: Colors.white54, size: 30),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _ConcentricArchesPainter(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ],
      );
    } else if (lower.contains('nexus')) {
      return Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 10,
            width: 120,
            height: 90,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
              ),
              child: Container(
                color: const Color(0xFF25284B),
                child: const Icon(Icons.record_voice_over_rounded, color: Colors.white60, size: 36),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _WaveLinesPainter(
                color: AppTheme.accentBlue.withOpacity(0.5),
              ),
            ),
          ),
        ],
      );
    } else if (lower.contains('lecture')) {
      return Stack(
        children: [
          Positioned(
            bottom: -10,
            left: -10,
            child: CustomPaint(
              size: const Size(180, 130),
              painter: _StackedSheetsPainter(),
            ),
          ),
        ],
      );
    } else if (lower.contains('exhibition')) {
      return Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _FanArchPainter(
                color: const Color(0xFF93C5FD).withOpacity(0.4),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _WaveLinesPainter(
              color: AppTheme.accentBlue.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArchedLinesPainter extends CustomPainter {
  final Color color;
  final int arcCount;

  _ArchedLinesPainter({required this.color, this.arcCount = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < arcCount; i++) {
      final rect = Rect.fromLTWH(
        20.0 + (i * 12),
        40.0 + (i * 10),
        size.width * 0.75,
        size.height * 0.75,
      );
      canvas.drawArc(rect, 3.14, 3.14, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConcentricArchesPainter extends CustomPainter {
  final Color color;

  _ConcentricArchesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.6), i * 22.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaveLinesPainter extends CustomPainter {
  final Color color;

  _WaveLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(0, size.height * 0.5 + (i * 14));
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2 + (i * 14),
        size.width,
        size.height * 0.6 + (i * 14),
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StackedSheetsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppTheme.accentBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 4; i++) {
      final path = Path();
      final offset = i * 14.0;
      path.moveTo(offset, size.height - offset);
      path.lineTo(offset + 100, size.height - offset - 50);
      path.lineTo(offset + 150, size.height - offset + 10);
      path.lineTo(offset + 50, size.height - offset + 60);
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FanArchPainter extends CustomPainter {
  final Color color;

  _FanArchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(Offset(size.width * 0.2, size.height * 1.1), i * 35.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}