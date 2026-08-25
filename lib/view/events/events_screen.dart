import 'package:flutter/material.dart';
import '../../model/events_data.dart';
import '../../constant/appTheme.dart';
import '../../services/events_service.dart';
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
  bool _isLoadingEvents = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (eventData.isEmpty) {
      setState(() => _isLoadingEvents = true);
    }
    try {
      final categories = await EventsService().getCategories(force: true);
      if (categories.isNotEmpty && mounted) {
        setState(() {
          eventData.clear();
          eventData.addAll(categories);
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching events: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingEvents = false);
      }
    }
  }

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
              child: _isLoadingEvents && eventData.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue,
                      ),
                    )
                  : SingleChildScrollView(
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
    final canPop = !widget.isTab && Navigator.canPop(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(44.0, 16.0, 24.0, 8.0),
      child: Row(
        children: [
          if (canPop) ...[
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Icon(
                Icons.chevron_left_rounded,
                color: textPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              'Events',
              style: TextStyle(
                color: textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.fontUnivers,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
    String? assetPath;

    if (lower.contains('competition') || lower.contains('robotics')) {
      assetPath = 'assets/robotics.png';
    } else if (lower.contains('workshop')) {
      assetPath = 'assets/workshops.png';
    } else if (lower.contains('nexus')) {
      assetPath = 'assets/nexus.png';
    } else if (lower.contains('lecture') || lower.contains('keynote')) {
      assetPath = 'assets/ls.png';
    } else if (lower.contains('night') || lower.contains('event')) {
      assetPath = 'assets/nightEvents.png';
    } else if (lower.contains('exhibition')) {
      assetPath = 'assets/exhibtions.png';
    } else if (lower.contains('hackathon')) {
      assetPath = 'assets/hackathons.png';
    }

    if (assetPath != null) {
      final String path = assetPath;
      return LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = constraints.maxHeight * 0.65;
          final borderRadius = imageHeight * 0.16;

          return Stack(
            children: [
              // Background painter accent
              Positioned.fill(
                child: CustomPaint(
                  painter: _WaveLinesPainter(
                    color: AppTheme.accentBlue.withOpacity(0.20),
                  ),
                ),
              ),

              // Proportionally sized artwork with circular rounded corners
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                height: imageHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Image.asset(
                        path,
                        fit: BoxFit.fill,
                        alignment: Alignment.center,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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