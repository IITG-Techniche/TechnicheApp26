import 'dart:math';
import 'package:flutter/material.dart';
import '../model/events_data.dart';
import '../utils/animate_gradient_background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'eventdetailpage.dart';

class _Star {
  final Offset position;
  final double radius;
  final double initialOpacity;
  final double twinkleSpeed;
  final double twinkleOffset;

  _Star({
    required this.position,
    required this.radius,
    required this.initialOpacity,
    required this.twinkleSpeed,
    required this.twinkleOffset,
  });
}

class SubCategoryScreen extends StatefulWidget {
  final String categoryTitle;
  final List<SubCategory> subCategories;

  const SubCategoryScreen({
    super.key,
    required this.categoryTitle,
    required this.subCategories,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen>
    with TickerProviderStateMixin {
  final Set<int> _expanded = {};
  int? _selectedStop;

  final double cardWidth = 100;
  final double collapsedCardHeight = 100;
  final double verticalSpacing = 120;
  final double eventTileMinHeight = 50;

  late AnimationController _starController;
  final List<_Star> _stars = [];
  final int _starCount = 300;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final random = Random();
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < _starCount; i++) {
        _stars.add(_Star(
          position: Offset(
            random.nextDouble() * size.width,
            random.nextDouble() * (size.height * 2),
          ),
          radius: random.nextDouble() * 1.8 + 0.6,
          initialOpacity: random.nextDouble() * 0.6 + 0.2,
          twinkleSpeed: random.nextDouble() * 0.5 + 0.2,
          twinkleOffset: random.nextDouble() * 2 * pi,
        ));
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  double _calculateEventsHeight(SubCategory subCat) {
    return subCat.events.length * (eventTileMinHeight + 8.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double sidePadding = 6;
    final double usableWidth =
        MediaQuery.of(context).size.width - (sidePadding * 2);
    final double leftX = 20;
    final double rightX = usableWidth - cardWidth - 60;
    final List<Offset> centers = [];
    double y = 40.0;
    for (int i = 0; i < widget.subCategories.length; i++) {
      final bool isLeft = i % 2 == 0;
      final double x = isLeft ? leftX : rightX;
      final bool isExpanded = _expanded.contains(i);
      final double cardH = collapsedCardHeight +
          (isExpanded ? _calculateEventsHeight(widget.subCategories[i]) : 0);
      centers.add(Offset(x + cardWidth / 2, y + cardH / 2));
      y += cardH + verticalSpacing;
    }
    final double totalHeight = y + 40;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.categoryTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          if (_stars.isNotEmpty)
            CustomPaint(
              size: Size.infinite,
              painter: _StarryBackgroundPainter(
                stars: _stars,
                animation: _starController,
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: sidePadding),
                child: SizedBox(
                  height: totalHeight,
                  width: usableWidth,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(usableWidth, totalHeight),
                        painter: _TrackPainter(
                          centers: centers,
                          trackColor: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      for (int i = 0; i < widget.subCategories.length; i++)
                        _buildStop(i, leftX, rightX, theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStop(int i, double leftX, double rightX, ThemeData theme) {
    final bool isLeft = i % 2 == 0;
    final bool isExpanded = _expanded.contains(i);
    final subCat = widget.subCategories[i];
    final double top = _calculateTopForIndex(i);

    return Positioned(
      top: top,
      left: isLeft ? leftX : rightX,
      child: GestureDetector(
        onTap: () {
          setState(() {
            final bool wasAlreadyExpanded = _expanded.contains(i);
            _expanded.clear();
            _selectedStop = i;
            if (!wasAlreadyExpanded) {
              _expanded.add(i);
            }
          });
        },
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _selectedStop == i ? Colors.amber : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: cardWidth,
                height: collapsedCardHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    subCat.imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subCat.title.split(' ').join('\n'),
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                for (var event in subCat.events)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailPage(
                            eventTitle: event.title,
                            event: event,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: cardWidth + 40,
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            event.title,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          if (event.redirectUrl != null) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () async {
                                  final url = Uri.parse(event.redirectUrl!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Cannot open registration link')),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Register Now'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTopForIndex(int index) {
    double y = 40.0;
    for (int i = 0; i < index; i++) {
      final bool isExpanded = _expanded.contains(i);
      final double cardH = collapsedCardHeight +
          (isExpanded ? _calculateEventsHeight(widget.subCategories[i]) : 0);
      y += cardH + verticalSpacing;
    }
    return y;
  }
}

class _StarryBackgroundPainter extends CustomPainter {
  final List<_Star> stars;
  final Animation<double> animation;

  _StarryBackgroundPainter({required this.stars, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final glowPaint = Paint();

    for (final star in stars) {
      final sineValue = sin(
          star.twinkleOffset + (animation.value * 2 * pi * star.twinkleSpeed));

      final normalizedSine = (sineValue + 1) / 2;

      final opacity = star.initialOpacity * normalizedSine;
      final glowOpacity = opacity * 0.5;
      glowPaint.color = Colors.white.withOpacity(glowOpacity);
      glowPaint.maskFilter =
          MaskFilter.blur(BlurStyle.normal, star.radius * 3.0);
      canvas.drawCircle(star.position, star.radius, glowPaint);
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(star.position, star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarryBackgroundPainter oldDelegate) {
    return false;
  }
}

class _TrackPainter extends CustomPainter {
  final List<Offset> centers;
  final Color trackColor;

  _TrackPainter({required this.centers, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = trackColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < centers.length - 1; i++) {
      final p1 = centers[i];
      final p2 = centers[i + 1];
      double horizontalPull = (p2.dx > p1.dx ? 1 : -1) * 80;
      final controlPoint = Offset(
        (p1.dx + p2.dx) / 2 + horizontalPull,
        (p1.dy + p2.dy) / 2,
      );
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, p2.dx, p2.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrackPainter oldDelegate) {
    return oldDelegate.centers != centers ||
        oldDelegate.trackColor != trackColor;
  }
}
